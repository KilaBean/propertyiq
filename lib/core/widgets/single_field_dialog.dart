import 'package:flutter/material.dart';

/// A small prompt dialog with a single text field. It owns its
/// [TextEditingController] and disposes it in its own State — which runs only
/// after the dialog's exit transition finishes, avoiding the "controller used
/// after being disposed" crash that happens when a caller disposes a
/// dialog-local controller right after `showDialog` returns.
///
/// Returns the entered text, or null if cancelled.
Future<String?> showSingleFieldDialog(
  BuildContext context, {
  required String title,
  required String label,
  String confirmLabel = 'Save',
  String initial = '',
  bool obscure = false,
  TextInputType? keyboardType,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _SingleFieldDialog(
      title: title,
      label: label,
      confirmLabel: confirmLabel,
      initial: initial,
      obscure: obscure,
      keyboardType: keyboardType,
    ),
  );
}

class _SingleFieldDialog extends StatefulWidget {
  const _SingleFieldDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.initial,
    required this.obscure,
    required this.keyboardType,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String initial;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  State<_SingleFieldDialog> createState() => _SingleFieldDialogState();
}

class _SingleFieldDialogState extends State<_SingleFieldDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
