import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/error_messages.dart';
import '../../../../shared/models/unit.dart';
import '../../../../shared/models/unit_status.dart';
import '../providers/unit_controller.dart';

/// Create (initial == null) or edit a unit. When editing, the [Unit] is passed
/// via GoRouter `extra` from the property detail screen.
class UnitFormScreen extends ConsumerStatefulWidget {
  const UnitFormScreen({super.key, required this.propertyId, this.initial});

  final String propertyId;
  final Unit? initial;

  @override
  ConsumerState<UnitFormScreen> createState() => _UnitFormScreenState();
}

class _UnitFormScreenState extends ConsumerState<UnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _label =
      TextEditingController(text: widget.initial?.label ?? '');
  late final TextEditingController _bedrooms = TextEditingController(
    text: (widget.initial?.bedrooms ?? 0).toString(),
  );
  late final TextEditingController _rent = TextEditingController(
    text: widget.initial?.baseRent.toString() ?? '',
  );
  late UnitStatus _status = widget.initial?.status ?? UnitStatus.vacant;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _label.dispose();
    _bedrooms.dispose();
    _rent.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(unitControllerProvider.notifier).save(
          id: widget.initial?.id,
          propertyId: widget.propertyId,
          label: _label.text.trim(),
          bedrooms: int.tryParse(_bedrooms.text.trim()) ?? 0,
          baseRent: num.tryParse(_rent.text.trim()) ?? 0,
          status: _status,
        );
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitControllerProvider);

    ref.listen(unitControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(friendlyError(next.error))));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit unit' : 'New unit')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _label,
                  decoration: const InputDecoration(
                    labelText: 'Label (e.g. Flat 2B)',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bedrooms,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Bedrooms'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rent,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(labelText: 'Base rent'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (num.tryParse(v.trim()) == null) return 'Enter a number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text('Status', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<UnitStatus>(
                  segments: const [
                    ButtonSegment(
                      value: UnitStatus.vacant,
                      label: Text('Vacant'),
                    ),
                    ButtonSegment(
                      value: UnitStatus.occupied,
                      label: Text('Occupied'),
                    ),
                  ],
                  selected: {_status},
                  onSelectionChanged: (s) => setState(() => _status = s.first),
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
                      : Text(_isEditing ? 'Save changes' : 'Create unit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
