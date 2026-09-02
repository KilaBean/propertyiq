import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/error_messages.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../shared/models/property.dart';
import '../providers/property_controller.dart';
import '../providers/property_providers.dart';

/// Create (no id) or edit (id given) a property. Loading of the existing record
/// is separated from the form so the form always starts with concrete values.
class PropertyFormScreen extends ConsumerWidget {
  const PropertyFormScreen({super.key, this.propertyId});

  final String? propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (propertyId == null) {
      return const _PropertyForm();
    }
    final detail = ref.watch(propertyDetailProvider(propertyId!));
    return AsyncValueView(
      value: detail,
      data: (property) => _PropertyForm(initial: property),
    );
  }
}

const _currencies = ['NGN', 'GHS', 'KES', 'ZAR', 'USD'];

class _PropertyForm extends ConsumerStatefulWidget {
  const _PropertyForm({this.initial});

  final Property? initial;

  @override
  ConsumerState<_PropertyForm> createState() => _PropertyFormState();
}

class _PropertyFormState extends ConsumerState<_PropertyForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _name =
      TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController _address =
      TextEditingController(text: widget.initial?.address ?? '');
  late String _currency = widget.initial?.currency ?? _currencies.first;
  XFile? _photo;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 75,
    );
    if (picked != null) setState(() => _photo = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final id = await ref.read(propertyControllerProvider.notifier).save(
          id: widget.initial?.id,
          name: _name.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
          currency: _currency,
        );
    if (id == null || !mounted) return;
    if (_photo != null) {
      await ref
          .read(propertyControllerProvider.notifier)
          .uploadPhoto(id, _photo!);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyControllerProvider);

    ref.listen(propertyControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(friendlyError(next.error))));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit property' : 'New property'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PhotoPicker(
                  photo: _photo,
                  existingPath: widget.initial?.photoPath,
                  onTap: _pickPhoto,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(
                    labelText: 'Address (optional)',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _currency,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: [
                    for (final c in _currencies)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (v) => setState(() => _currency = v ?? _currency),
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
                      : Text(_isEditing ? 'Save changes' : 'Create property'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends ConsumerWidget {
  const _PhotoPicker({
    required this.photo,
    required this.existingPath,
    required this.onTap,
  });

  final XFile? photo;
  final String? existingPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    Widget content;
    if (photo != null) {
      content = Image.file(File(photo!.path), fit: BoxFit.cover);
    } else if (existingPath != null && existingPath!.isNotEmpty) {
      final url = ref.watch(propertyPhotoUrlProvider(existingPath!));
      content = url.when(
        data: (u) => Image.network(u, fit: BoxFit.cover),
        loading: () => Container(color: scheme.surfaceContainerHighest),
        error: (_, _) => Icon(Icons.broken_image_outlined,
            color: scheme.onSurfaceVariant),
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, color: scheme.primary, size: 28),
          const SizedBox(height: 6),
          Text('Add cover photo', style: Theme.of(context).textTheme.bodySmall),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}
