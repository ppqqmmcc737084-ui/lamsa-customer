import 'package:flutter/material.dart';
import 'package:lamsa_customer/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/language_names.dart';
import '../../services/locale_service.dart';
import '../../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _languageTile({required String title, required bool selected, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w500)),
      trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.instance.themeMode,
            builder: (context, mode, _) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(AppRadius.medium)),
                child: SwitchListTile(
                  value: mode == ThemeMode.dark,
                  onChanged: (value) => ThemeService.instance.toggle(value),
                  title: Text(l10n.settingsDarkMode, style: const TextStyle(fontWeight: FontWeight.w700)),
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                  contentPadding: EdgeInsets.zero,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<Locale?>(
            valueListenable: LocaleService.instance.locale,
            builder: (context, current, _) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(AppRadius.medium)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language_rounded, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(l10n.settingsLanguage, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _languageTile(
                      title: l10n.languageSystem,
                      selected: current == null,
                      onTap: () => LocaleService.instance.set(null),
                    ),
                    ...AppLocalizations.supportedLocales.map((locale) => _languageTile(
                          title: kLanguageNames[locale.languageCode] ?? locale.languageCode,
                          selected: current?.languageCode == locale.languageCode,
                          onTap: () => LocaleService.instance.set(locale),
                        )),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(AppRadius.medium)),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(l10n.settingsVersion('1.0.0'), style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),    
        ],
      ),
    );
  }
}