import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The two languages the app ships with. Persisted locally so the choice
/// survives a restart; it is a device preference, not appointment data.
class LocaleController extends ChangeNotifier {
  static const _key = 'locale';
  static const supported = [Locale('en'), Locale('ar')];

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      _locale = supported.firstWhere((l) => l.languageCode == code,
          orElse: () => supported.first);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
