import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/rent_cycle.dart';
import '../../../../shared/models/tenancy.dart';
import '../../../../shared/models/tenancy_status.dart';
import '../providers/tenancy_controller.dart';
import '../widgets/tenant_credentials.dart';

/// Assign a tenant to a unit (create) or edit an existing tenancy. On create
/// the tenant is invited by email; the email/unit are fixed once created.
class TenancyFormScreen extends ConsumerStatefulWidget {
  const TenancyFormScreen({
    super.key,
    required this.unitId,
    this.initial,
  });

  final String unitId;
  final Tenancy? initial;

  @override
  ConsumerState<TenancyFormScreen> createState() => _TenancyFormScreenState();
}

class _TenancyFormScreenState extends ConsumerState<TenancyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName = TextEditingController();
  late final TextEditingController _phone = TextEditingController();
  late final TextEditingController _email =
      TextEditingController(text: widget.initial?.tenantEmail ?? '');
  late final TextEditingController _rent = TextEditingController(
    text: widget.initial?.rentAmount.toString() ?? '',
  );
  late final TextEditingController _utility = TextEditingController(
    text: widget.initial?.utilityAmount.toString() ?? '',
  );
  late final TextEditingController _deposit = TextEditingController(
    text: widget.initial?.depositAmount.toString() ?? '',
  );
  late final TextEditingController _emergency = TextEditingController(
    text: widget.initial?.emergencyContact ?? '',
  );
  late RentCycle _cycle = widget.initial?.rentCycle ?? RentCycle.monthly;
  late DateTime _start = widget.initial?.startDate ?? DateTime.now();
  late DateTime? _end = widget.initial?.endDate;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _rent.dispose();
    _utility.dispose();
    _deposit.dispose();
    _emergency.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _requiredNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (num.tryParse(v.trim()) == null) return 'Enter a number';
    return null;
  }

  num _numOf(TextEditingController c) => num.tryParse(c.text.trim()) ?? 0;

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _start : (_end ?? _start);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(tenancyControllerProvider.notifier);
    final rent = num.tryParse(_rent.text.trim()) ?? 0;

    if (_isEditing) {
      final ok = await notifier.edit(
        id: widget.initial!.id,
        rentAmount: rent,
        utilityAmount: _numOf(_utility),
        depositAmount: _numOf(_deposit),
        emergencyContact: _emergency.text.trim(),
        rentCycle: _cycle,
        startDate: _start,
        endDate: _end,
        status: widget.initial!.status == TenancyStatus.ended
            ? TenancyStatus.ended
            : TenancyStatus.active,
      );
      if (ok && mounted) context.pop();
      return;
    }

    final invite = await notifier.assign(
      unitId: widget.unitId,
      tenantEmail: _email.text.trim(),
      fullName: _fullName.text.trim(),
      phone: _phone.text.trim(),
      rentAmount: rent,
      utilityAmount: _numOf(_utility),
      depositAmount: _numOf(_deposit),
      emergencyContact: _emergency.text.trim(),
      rentCycle: _cycle,
      startDate: _start,
      endDate: _end,
    );
    if (invite == null || !mounted) return;
    await showTenantCredentialsDialog(
      context,
      email: invite.email,
      password: invite.password,
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tenancyControllerProvider);

    ref.listen(tenancyControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(friendlyError(next.error))));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit tenancy' : 'Assign tenant'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            // Errors surface as the user leaves a field, not only in one dump at
            // submit -- CLAUDE.md's FORMS section calls for inline validation.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_isEditing) ...[
                  TextFormField(
                    controller: _fullName,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _email,
                  enabled: !_isEditing,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Tenant email'),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 16),
                if (!_isEditing) ...[
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _rent,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(labelText: 'Rent amount'),
                  validator: _requiredNumber,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _utility,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration:
                      const InputDecoration(labelText: 'Monthly utility'),
                  validator: _requiredNumber,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deposit,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration:
                      const InputDecoration(labelText: 'Security deposit'),
                  validator: _requiredNumber,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RentCycle>(
                  initialValue: _cycle,
                  decoration: const InputDecoration(labelText: 'Rent cycle'),
                  items: [
                    for (final c in RentCycle.values)
                      DropdownMenuItem(value: c, child: Text(c.label)),
                  ],
                  onChanged: (v) => setState(() => _cycle = v ?? _cycle),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start date'),
                  subtitle: Text(formatDate(_start)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () => _pickDate(isStart: true),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End date (optional)'),
                  subtitle: Text(_end == null ? 'None' : formatDate(_end!)),
                  trailing: _end == null
                      ? const Icon(Icons.calendar_today_outlined)
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear end date',
                          onPressed: () => setState(() => _end = null),
                        ),
                  onTap: () => _pickDate(isStart: false),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emergency,
                  decoration:
                      const InputDecoration(labelText: 'Emergency contact'),
                  validator: _required,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Assign tenant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
