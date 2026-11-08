import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  LocaleService._internal();
  static final LocaleService instance = LocaleService._internal();

  static const _key = 'app_locale';

  /// null = لغة الجهاز
  final ValueNotifier<Locale?> locale = ValueNotifier(null);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    locale.value = code == null ? null : Locale(code);
  }

  Future<void> set(Locale? newLocale) async {
    locale.value = newLocale;
    final prefs = await SharedPreferences.getInstance();
    if (newLocale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, newLocale.languageCode);
    }
  }
}