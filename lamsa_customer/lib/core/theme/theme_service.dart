import 'package:flutter/material.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}