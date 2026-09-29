import '../l10n/app_localizations.dart';

/// Form-field validators shared by every screen, so the same field is
/// checked the same way everywhere.
class Validators {
  const Validators(this.t);
  final AppLocalizations t;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phone = RegExp(r'^[0-9+\-\s()]{6,20}$');

  /// Any non-blank text; [message] defaults to "Enter a name".
  String? Function(String?) required([String? message]) =>
      (v) => v == null || v.trim().isEmpty ? (message ?? t.nameRequired) : null;

  String? email(String? v) =>
      v != null && _email.hasMatch(v.trim()) ? null : t.emailInvalid;

  /// A new password (sign-up, change password, new doctor account).
  String? newPassword(String? v) => v != null && v.length >= 6 ? null : t.passwordTooShort;

  /// An existing password — only checked for being filled in.
  String? currentPassword(String? v) => v != null && v.isNotEmpty ? null : t.passwordRequired;

  /// Optional: blank is fine, otherwise it must look like a phone number.
  String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return _phone.hasMatch(v.trim()) ? null : t.phoneInvalid;
  }
}
