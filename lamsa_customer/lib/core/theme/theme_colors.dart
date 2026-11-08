import 'package:flutter/material.dart';
import 'app_theme.dart';

/// ألوان تتبدل تلقائياً بين الوضع الفاتح والليلي.
extension ThemeColorsX on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get cardBg => isDarkMode ? AppDarkColors.surface : AppColors.white;
  Color get textMain => isDarkMode ? AppDarkColors.text : AppColors.dark;
  Color get textMuted => isDarkMode ? AppDarkColors.grey : AppColors.grey;
  Color get fieldBg => isDarkMode ? AppDarkColors.lightGrey : AppColors.lightGrey;
  Color get softShadow => Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.06);
}
