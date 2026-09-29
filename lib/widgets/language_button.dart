import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/locale_controller.dart';
import '../state/locale_scope.dart';

/// A globe icon that switches between the app's languages.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final controller = LocaleScope.of(context);
    final current = Localizations.localeOf(context).languageCode;
    String name(Locale l) => l.languageCode == 'ar' ? t.languageArabic : t.languageEnglish;
    return PopupMenuButton<Locale>(
      tooltip: t.languageLabel,
      icon: const Icon(Icons.language),
      onSelected: controller.setLocale,
      itemBuilder: (_) => [
        for (final l in LocaleController.supported)
          CheckedPopupMenuItem(
            value: l,
            checked: l.languageCode == current,
            child: Text(name(l)),
          ),
      ],
    );
  }
}
