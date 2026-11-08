// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lamsa';

  @override
  String get navHome => 'Home';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navCart => 'Cart';

  @override
  String get navProfile => 'Account';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsLanguage => 'Language';

  @override
  String settingsVersion(Object version) {
    return 'App version: $version';
  }

  @override
  String get languageSystem => 'Device language';

  @override
  String get currencySymbol => 'YER';
}
