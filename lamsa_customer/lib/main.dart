import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lamsa_customer/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await AuthService.instance.ensureSignedIn();
  } catch (e) {
    debugPrint('فشل تسجيل الدخول المجهول: $e');
  }
  await LocaleService.instance.load();
  runApp(const LamsaApp());
}

class LamsaApp extends StatelessWidget {
  const LamsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: LocaleService.instance.locale,
          builder: (context, locale, _) {
            return MaterialApp(
              onGenerateTitle: (context) => AppLocalizations.of(context).appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}