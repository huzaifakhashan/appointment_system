import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../state/app_scope.dart';
import '../utils/error_messages.dart';
import '../utils/text_direction.dart';
import '../utils/validators.dart';
import '../widgets/feedback.dart';

/// The signed-in user's own account: name, phone, email, password.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final profile = AppScope.of(context).profile;
    if (profile == null) return const SizedBox.shrink(); // signing out
    return Scaffold(
      appBar: AppBar(title: Text(t.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            icon: Icons.person,
            title: t.personalInfoTitle,
            children: [
              // A doctor's public name lives in their schedule settings.
              if (profile.role == Role.provider)
                _InfoNote(t.doctorNameNote)
              else
                _SingleFieldForm(
                  initialValue: profile.name,
                  label: t.nameLabel,
                  validator: Validators(t).required(),
                  onSave: AppScope.of(context).updateMyName,
                  successMessage: t.nameUpdated,
                ),
              const SizedBox(height: 12),
              _SingleFieldForm(
                initialValue: profile.phone,
                label: t.phoneLabel,
                keyboardType: TextInputType.phone,
                validator: Validators(t).phone,
                onSave: AppScope.of(context).updateMyPhone,
                successMessage: t.phoneUpdated,
              ),
            ],
          ),
          _Section(
            icon: Icons.email,
            title: t.emailLabel,
            children: [
              // Only patients must verify (to book). Staff accounts are made
              // by an admin, so for them it's just their sign-in address.
              if (profile.role == Role.customer)
                _EmailStatus(profile: profile)
              else
                Text(ltr(profile.email)),
            ],
          ),
          _Section(
            icon: Icons.lock,
            title: t.changePasswordTitle,
            children: const [_ChangePasswordForm()],
          ),
          // Staff accounts are removed by an admin, never by themselves.
          if (profile.role == Role.customer) const _DeleteAccountSection(),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.children});
  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      );
}

/// One text field with its own Save button (name, phone).
class _SingleFieldForm extends StatefulWidget {
  const _SingleFieldForm({
    required this.initialValue,
    required this.label,
    required this.validator,
    required this.onSave,
    required this.successMessage,
    this.keyboardType,
  });

  final String initialValue;
  final String label;
  final String? Function(String?) validator;
  final Future<void> Function(String) onSave;
  final String successMessage;
  final TextInputType? keyboardType;

  @override
  State<_SingleFieldForm> createState() => _SingleFieldFormState();
}

class _SingleFieldFormState extends State<_SingleFieldForm> {
  late final _controller = TextEditingController(text: widget.initialValue);
  final _form = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    await runWithFeedback(context, () => widget.onSave(_controller.text.trim()),
        success: widget.successMessage);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              // Phone numbers read left-to-right even in Arabic, or the
              // "+" jumps to the wrong end.
              textDirection:
                  widget.keyboardType == TextInputType.phone ? TextDirection.ltr : null,
              textCapitalization: widget.keyboardType == null
                  ? TextCapitalization.words
                  : TextCapitalization.none,
              decoration: InputDecoration(labelText: widget.label),
              validator: widget.validator,
              onFieldSubmitted: (_) => _save(),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: BusyButton(
              busy: _saving,
              onPressed: _save,
              label: AppLocalizations.of(context)!.save,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailStatus extends StatefulWidget {
  const _EmailStatus({required this.profile});
  final UserProfile profile;

  @override
  State<_EmailStatus> createState() => _EmailStatusState();
}

class _EmailStatusState extends State<_EmailStatus> {
  bool _sending = false;
  bool _refreshing = false;

  Future<void> _resend() async {
    final t = AppLocalizations.of(context)!;
    setState(() => _sending = true);
    await runWithFeedback(context, AppScope.of(context).sendEmailVerification,
        success: t.verificationEmailSentTo(widget.profile.email));
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _refresh() async {
    final t = AppLocalizations.of(context)!;
    final state = AppScope.of(context);
    setState(() => _refreshing = true);
    var verified = false;
    final ok = await runWithFeedback(context, () async {
      verified = await state.reloadAndCheckVerified();
    });
    if (!mounted) return;
    setState(() => _refreshing = false);
    if (ok && !verified) showSnack(context, t.stillNotVerified);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final verified = widget.profile.emailVerified;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(widget.profile.email)),
            Chip(
              avatar: Icon(
                verified ? Icons.check_circle : Icons.error_outline,
                size: 18,
                color: verified ? Colors.green : Colors.orange,
              ),
              label: Text(verified ? t.emailVerifiedLabel : t.emailNotVerifiedLabel),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        if (!verified)
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: _sending ? null : _resend,
                child: Text(t.resendVerificationEmail),
              ),
              OutlinedButton(
                onPressed: _refreshing ? null : _refresh,
                child: Text(t.refreshStatus),
              ),
            ],
          ),
      ],
    );
  }
}

/// Patients only: permanently delete the account.
class _DeleteAccountSection extends StatelessWidget {
  const _DeleteAccountSection();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final danger = theme.colorScheme.error;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: danger.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.delete_forever, size: 20, color: danger),
                const SizedBox(width: 8),
                Text(t.deleteAccountTitle,
                    style: theme.textTheme.titleMedium?.copyWith(color: danger)),
              ],
            ),
            const SizedBox(height: 12),
            Text(t.deleteAccountBody),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: danger,
                  side: BorderSide(color: danger),
                ),
                icon: const Icon(Icons.delete_outline),
                label: Text(t.deleteAccountTitle),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const _DeleteAccountDialog(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks for the password, then deletes. Errors (e.g. a wrong password)
/// stay inside the dialog so the user can try again.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (!_form.currentState!.validate()) return;
    final t = AppLocalizations.of(context)!;
    final state = AppScope.of(context);
    // The app-wide messenger outlives this dialog and the profile screen,
    // so the confirmation still shows on the sign-in screen afterwards.
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await state.deleteMyAccount(_password.text);
      // Signing out pops every screen back to the sign-in one by itself.
      messenger.showSnackBar(SnackBar(content: Text(t.accountDeleted)));
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(t, e, passwordOnly: true));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final danger = Theme.of(context).colorScheme.error;
    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: danger),
      title: Text(t.deleteAccountConfirmTitle),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.deleteAccountBody),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(labelText: t.deleteAccountPasswordLabel),
              validator: Validators(t).currentPassword,
              onFieldSubmitted: (_) => _delete(),
            ),
            _FormError(_error),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: danger),
          onPressed: _busy ? null : _delete,
          child: _busy ? const ButtonSpinner(size: 16) : Text(t.deleteAccountConfirm),
        ),
      ],
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  const _ChangePasswordForm();

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final t = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AppScope.of(context)
          .changePassword(currentPassword: _current.text, newPassword: _new.text);
      _current.clear();
      _new.clear();
      _confirm.clear();
      if (mounted) showSnack(context, t.passwordUpdated);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(t, e, passwordOnly: true));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final v = Validators(t);
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _current,
            obscureText: true,
            decoration: InputDecoration(labelText: t.currentPasswordLabel),
            validator: v.currentPassword,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _new,
            obscureText: true,
            decoration: InputDecoration(labelText: t.newPasswordLabel),
            validator: v.newPassword,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirm,
            obscureText: true,
            decoration: InputDecoration(labelText: t.confirmPasswordLabel),
            validator: (value) => value == _new.text ? null : t.passwordsDontMatch,
          ),
          _FormError(_error),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: BusyButton(busy: _busy, onPressed: _submit, label: t.updatePassword),
          ),
        ],
      ),
    );
  }
}

class _FormError extends StatelessWidget {
  const _FormError(this.error);
  final String? error;

  @override
  Widget build(BuildContext context) => error == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        );
}
