import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_settings_provider.dart';

class OptionsMenuButton extends StatelessWidget {
  const OptionsMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'settings') {
          _showSettingsBottomSheet(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'settings',
          child: Text(context.l10n.settings),
        ),
      ],
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Consumer<AppSettingsProvider>(
          builder: (context, settings, _) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.settings,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(context.l10n.theme),
                  DropdownButton<ThemeMode>(
                    isExpanded: true,
                    value: settings.themeMode,
                    onChanged: (value) {
                      if (value != null) settings.setThemeMode(value);
                    },
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(context.l10n.system),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(context.l10n.light),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(context.l10n.dark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(context.l10n.language),
                  DropdownButton<Locale>(
                    isExpanded: true,
                    value: settings.locale,
                    onChanged: (value) {
                      if (value != null) settings.setLocale(value);
                    },
                    items: [
                      DropdownMenuItem(
                        value: const Locale('en'),
                        child: Text(context.l10n.english),
                      ),
                      DropdownMenuItem(
                        value: const Locale('pt', 'BR'),
                        child: Text(context.l10n.portugueseBrazil),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
