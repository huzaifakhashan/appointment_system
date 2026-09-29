import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/error_messages.dart';

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Runs [action], then shows [success] (if given) or a readable error.
/// Returns whether it succeeded. Every button that talks to the server goes
/// through this, so a failure is never silently swallowed.
Future<bool> runWithFeedback(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final t = AppLocalizations.of(context)!;
  void show(String m) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));
  try {
    await action();
    if (success != null) show(success);
    return true;
  } catch (e) {
    debugPrint('Action failed: $e');
    show(errorMessage(t, e));
    return false;
  }
}

/// A small spinner sized to sit inside a button while it's busy.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key, this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: size,
        width: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
}

/// A [FilledButton] that shows a spinner and ignores taps while [busy].
class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.busy,
    required this.onPressed,
    required this.label,
  });

  final bool busy;
  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: busy ? null : onPressed,
        child: busy ? const ButtonSpinner(size: 16) : Text(label),
      );
}
