// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'لمسة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navCart => 'السلة';

  @override
  String get navProfile => 'حسابي';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsDarkMode => 'الوضع الليلي';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String settingsVersion(Object version) {
    return 'إصدار التطبيق: $version';
  }

  @override
  String get languageSystem => 'لغة الجهاز';

  @override
  String get currencySymbol => 'ر.ي';
}
