import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/app_scope.dart';
import '../utils/error_messages.dart';
import '../utils/validators.dart';
import '../widgets/dialogs.dart';
import '../widgets/feedback.dart';
import '../widgets/language_button.dart';

/// Sign in (everyone) and sign up (patients only).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _isStaff = false;
  bool _signUp = false;
  bool _busy = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _setMode({bool? isStaff, bool? signUp}) => setState(() {
        _isStaff = isStaff ?? _isStaff;
        // Staff accounts are created by the admin, never self-registered.
        _signUp = !_isStaff && (signUp ?? _signUp);
        _error = null;
      });

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_signUp) {
        await state.signUp(_name.text, _email.text, _password.text);
      } else {
        await state.signIn(_email.text, _password.text);
      }
      // On success the app swaps this screen out by itself (see main.dart).
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(t, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgotPassword() async {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context)!;
    final email = await showTextInputDialog(
      context,
      title: t.resetPasswordTitle,
      label: t.emailLabel,
      confirmLabel: t.sendResetLink,
      initialValue: _email.text.trim(),
      keyboardType: TextInputType.emailAddress,
      validator: Validators(t).email,
    );
    if (email == null || !mounted) return;
    // Always show the same message, whether or not the account exists, so
    // this can't be used to find out which emails are registered.
    try {
      await state.sendPasswordReset(email);
    } catch (_) {}
    if (mounted) showSnack(context, t.resetEmailSent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final v = Validators(t);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _form,
              child: AutofillGroup(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Icon(Icons.event_available, size: 72, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(t.appTitle,
                        textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    // Only changes the form's wording — the account's real role,
                    // stored server-side, decides what it can actually do.
                    Center(
                      child: SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(
                              value: false,
                              label: Text(t.tabPatient),
                              icon: const Icon(Icons.person)),
                          ButtonSegment(
                              value: true,
                              label: Text(t.tabStaff),
                              icon: const Icon(Icons.medical_services)),
                        ],
                        selected: {_isStaff},
                        onSelectionChanged: (s) => _setMode(isStaff: s.first),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_signUp) ...[
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        decoration: InputDecoration(
                          labelText: t.nameLabel,
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: v.required(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: t.emailLabel,
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: v.email,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: !_showPassword,
                      autofillHints: [
                        _signUp ? AutofillHints.newPassword : AutofillHints.password
                      ],
                      decoration: InputDecoration(
                        labelText: t.passwordLabel,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      validator: _signUp ? v.newPassword : v.currentPassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (!_signUp)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: _busy ? null : _forgotPassword,
                          child: Text(t.forgotPassword),
                        ),
                      )
                    else
                      const SizedBox(height: 16),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.colorScheme.error)),
                      ),
                    BusyButton(
                      busy: _busy,
                      onPressed: _submit,
                      label: _signUp ? t.createAccount : t.signIn,
                    ),
                    const SizedBox(height: 8),
                    if (_isStaff)
                      Text(
                        t.staffSignInHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      )
                    else
                      TextButton(
                        onPressed: _busy ? null : () => _setMode(signUp: !_signUp),
                        child: Text(_signUp ? t.alreadyHaveAccount : t.newHere),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
