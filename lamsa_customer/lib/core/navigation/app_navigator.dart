import 'package:flutter/foundation.dart';

/// متحكم التنقل المركزي للتطبيق
/// أي شاشة تقدر تطلب التبديل بين التبويبات الرئيسية
class AppNavigator {
  AppNavigator._internal();
  static final AppNavigator instance = AppNavigator._internal();

  final ValueNotifier<int> currentTab = ValueNotifier<int>(0);

  int get tab => currentTab.value;

  void goToTab(int index) {
    if (index < 0 || index == currentTab.value) return;
    currentTab.value = index;
  }
}