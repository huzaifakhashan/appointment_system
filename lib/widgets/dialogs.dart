import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Asks a yes/no question. Resolves to true only if [confirmLabel] is tapped.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? body,
  required String confirmLabel,
  String? cancelLabel,
}) async {
  final t = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel ?? t.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Asks for one line of text. Resolves to the trimmed text, or null if
/// cancelled.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String initialValue = '',
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _TextInputDialog(
        title: title,
        label: label,
        confirmLabel: confirmLabel,
        initialValue: initialValue,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.initialValue,
    this.keyboardType,
    this.validator,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String initialValue;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.keyboardType == TextInputType.emailAddress
              ? TextCapitalization.none
              : TextCapitalization.words,
          decoration: InputDecoration(labelText: widget.label),
          validator: widget.validator,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
