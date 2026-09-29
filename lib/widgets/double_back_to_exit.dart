import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

/// Wraps the app's root screen so the back button/gesture doesn't just quit
/// on the first press — it asks for a second press within a couple seconds,
/// the common "press back again to exit" pattern.
class DoubleBackToExit extends StatefulWidget {
  const DoubleBackToExit({super.key, required this.child});
  final Widget child;

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  DateTime? _lastPress;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastPress != null && now.difference(_lastPress!) < const Duration(seconds: 2)) {
          SystemNavigator.pop();
          return;
        }
        _lastPress = now;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.pressBackAgainToExit),
            duration: const Duration(seconds: 2),
          ));
      },
      child: widget.child,
    );
  }
}
