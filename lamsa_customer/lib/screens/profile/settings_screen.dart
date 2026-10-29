import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'الإعدادات\n\n'
            'هذه صفحة الإعدادات في تطبيق لمسة للعميل.\n'
            'يمكننا إضافة الخيارات المطلوبة إليها لاحقًا.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}
