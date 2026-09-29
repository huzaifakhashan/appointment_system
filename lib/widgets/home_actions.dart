import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/profile_screen.dart';
import 'language_button.dart';
import 'sign_out_button.dart';

/// The app-bar actions every home screen shares: language, profile, sign
/// out — with any screen-specific [extra] actions placed first.
List<Widget> homeActions(BuildContext context, {List<Widget> extra = const []}) {
  final t = AppLocalizations.of(context)!;
  return [
    ...extra,
    const LanguageButton(),
    IconButton(
      tooltip: t.profileTooltip,
      icon: const Icon(Icons.account_circle),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
    ),
    const SignOutButton(),
  ];
}
