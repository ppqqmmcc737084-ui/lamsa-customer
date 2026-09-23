import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _initOneSignal();
  await _signInAnonymously();

  runApp(const LamsaApp());
}

/// تهيئة OneSignal وربط مستخدم الإشعارات بالحساب
Future<void> _initOneSignal() async {
  try {
    OneSignal.initialize('e691eb75-44b7-440c-8801-ca0f54cf66a1');
    await OneSignal.Notifications.requestPermission(true);

    final userId = AuthService.instance.currentUserId;
    if (userId != null) await OneSignal.login(userId);
  } catch (e) {
    debugPrint('⚠️ فشل تهيئة OneSignal: $e');
  }
}

/// دخول مجهول — المستخدم يقدر يتصفح ويطلب بدون تسجيل
Future<void> _signInAnonymously() async {
  try {
    await AuthService.instance.ensureSignedIn();
  } catch (e) {
    debugPrint('⚠️ فشل تسجيل الدخول المجهول: $e');
  }
}

class LamsaApp extends StatelessWidget {
  const LamsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لمسة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}