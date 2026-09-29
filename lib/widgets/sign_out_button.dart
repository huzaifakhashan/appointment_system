import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/app_scope.dart';
import 'feedback.dart';

/// A sign-out icon button that shows a spinner while it runs and a message
/// if it fails, instead of silently doing nothing on a slow connection.
class SignOutButton extends StatefulWidget {
  const SignOutButton({super.key});

  @override
  State<SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<SignOutButton> {
  bool _busy = false;

  Future<void> _signOut() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await AppScope.of(context).signOut();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.signOutFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.signOut,
      icon: _busy ? const ButtonSpinner() : const Icon(Icons.logout),
      onPressed: _busy ? null : _signOut,
    );
  }
}
