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
                if (_isEditing) ...[
                  const SizedBox(height: 20),
                  _DerivedStatusNote(status: widget.initial!.status),
                ],
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

/// Occupancy is derived from the unit's tenancies by the database (migration
/// 0012), so it is shown here rather than offered as an editable control —
/// a toggle would let the manager set a value the next tenancy change silently
/// overwrites.
class _DerivedStatusNote extends StatelessWidget {
  const _DerivedStatusNote({required this.status});

  final UnitStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final occupied = status == UnitStatus.occupied;
    return Semantics(
      label: 'Occupancy status: ${status.label}. '
          "Set automatically by this unit's tenancies.",
      readOnly: true,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                occupied ? Icons.person_outline : Icons.meeting_room_outlined,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      occupied
                          ? 'Set automatically by the active tenancy.'
                          : 'Assign a tenant to mark this unit occupied.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
