import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/app_scope.dart';
import '../utils/error_messages.dart';
import '../widgets/feedback.dart';
import '../widgets/language_button.dart';
import '../widgets/sign_out_button.dart';

/// Shown instead of the patient home screen until the account's email is
/// verified, so a made-up address can't be used to book real appointments.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sending = false;
  bool _refreshing = false;
  // The outcome of the last send, kept on screen (a snackbar is easy to miss).
  String? _sendResult;
  bool _sendFailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Right after sign-up, send the first verification email from here, so
    // that if it fails the reason is shown instead of lost.
    if (AppScope.of(context).takeVerificationEmailDue()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _send();
      });
    }
  }

  Future<void> _send() async {
    final t = AppLocalizations.of(context)!;
    final state = AppScope.of(context);
    setState(() {
      _sending = true;
      _sendResult = null;
    });
    try {
      await state.sendEmailVerification();
      _sendFailed = false;
      _sendResult = t.verificationEmailSentTo(state.profile?.email ?? '');
    } catch (e) {
      debugPrint('Verification email failed: $e');
      _sendFailed = true;
      _sendResult = errorMessage(t, e);
    }
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _refresh() async {
    final t = AppLocalizations.of(context)!;
    final state = AppScope.of(context);
    setState(() => _refreshing = true);
    var verified = false;
    await runWithFeedback(context, () async {
      verified = await state.reloadAndCheckVerified();
    });
    if (!mounted) return;
    setState(() => _refreshing = false);
    // Once verified, main.dart swaps this screen out by itself.
    if (!verified) showSnack(context, t.stillNotVerified);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: const [LanguageButton(), SignOutButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Icon(Icons.mark_email_unread, size: 72, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(t.verifyEmailTitle,
                    textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(t.verifyEmailBody(state.profile?.email ?? ''),
                    textAlign: TextAlign.center),
                // After a successful send, the result below already says
                // where to look, so don't repeat it here.
                if (_sendFailed || _sendResult == null) ...[
                  const SizedBox(height: 4),
                  Text(t.checkSpamHint,
                      textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: 24),
                if (_sending)
                  const Center(child: ButtonSpinner())
                else if (_sendResult != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_sendFailed ? Icons.error_outline : Icons.check_circle,
                          size: 18,
                          color: _sendFailed ? theme.colorScheme.error : Colors.green),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(_sendResult!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _sendFailed ? theme.colorScheme.error : null)),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                BusyButton(busy: _refreshing, onPressed: _refresh, label: t.refreshStatus),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _sending ? null : _send,
                  child: Text(t.resendVerificationEmail),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
