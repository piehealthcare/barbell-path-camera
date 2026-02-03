import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:point_barbell_path/core/l10n/generated/app_localizations.dart';

import '../../app.dart';
import '../../core/router/app_router.dart';
import '../../data/local/preferences/app_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.darkMode),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(darkModeProvider.notifier).state = value;
              AppPreferences.setDarkMode(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: Text(l10n.calibration),
            subtitle: Text(l10n.calibrationDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.calibration),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            subtitle: Text('${l10n.version} 1.0.0'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final languages = {
      'ko': '한국어',
      'en': 'English',
      'ja': '日本語',
      'zh': '中文 (简体)',
      'zh_TW': '中文 (繁體)',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'pt': 'Português',
    };

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.language),
        children: languages.entries.map((entry) {
          return SimpleDialogOption(
            onPressed: () {
              final locale = entry.key.contains('_')
                  ? Locale(entry.key.split('_')[0], entry.key.split('_')[1])
                  : Locale(entry.key);
              ref.read(localeProvider.notifier).state = locale;
              AppPreferences.setLanguage(entry.key);
              Navigator.pop(context);
            },
            child: Text(entry.value),
          );
        }).toList(),
      ),
    );
  }
}
