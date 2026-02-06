import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../providers/app_settings_provider.dart';

class OptionsMenuButton extends StatelessWidget {
  const OptionsMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: context.l10n.settings,
      onPressed: () => _showSettingsBottomSheet(context),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Consumer<AppSettingsProvider>(
            builder: (context, settings, _) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.settings,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          context.l10n.settings,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),

                    // Theme Setting
                    _buildSettingSection(
                      context: context,
                      icon: Icons.palette_outlined,
                      iconColor: Colors.purple,
                      title: context.l10n.theme,
                      child: _buildStyledDropdown<ThemeMode>(
                        context: context,
                        value: settings.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            settings.setThemeMode(value);
                          }
                        },
                        items: [
                          _buildDropdownItem(
                            context: context,
                            value: ThemeMode.system,
                            icon: Icons.brightness_auto,
                            label: context.l10n.system,
                          ),
                          _buildDropdownItem(
                            context: context,
                            value: ThemeMode.light,
                            icon: Icons.light_mode,
                            label: context.l10n.light,
                          ),
                          _buildDropdownItem(
                            context: context,
                            value: ThemeMode.dark,
                            icon: Icons.dark_mode,
                            label: context.l10n.dark,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Language Setting
                    _buildSettingSection(
                      context: context,
                      icon: Icons.language,
                      iconColor: Colors.blue,
                      title: context.l10n.language,
                      child: _buildStyledDropdown<Locale>(
                        context: context,
                        value: settings.locale,
                        onChanged: (value) {
                          if (value != null) {
                            settings.setLocale(value);
                          }
                        },
                        items: [
                          _buildDropdownItem(
                            context: context,
                            value: const Locale('en'),
                            emoji: '🇺🇸',
                            label: context.l10n.english,
                          ),
                          _buildDropdownItem(
                            context: context,
                            value: const Locale('pt', 'BR'),
                            emoji: '🇧🇷',
                            label: context.l10n.portugueseBrazil,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSettingSection({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildStyledDropdown<T>({
    required BuildContext context,
    required T value,
    required ValueChanged<T?> onChanged,
    required List<DropdownMenuItem<T>> items,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
          dropdownColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }

  DropdownMenuItem<T> _buildDropdownItem<T>({
    required BuildContext context,
    required T value,
    IconData? icon,
    String? emoji,
    required String label,
  }) {
    return DropdownMenuItem<T>(
      value: value,
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
          ] else if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 12),
          ],
          Text(label),
        ],
      ),
    );
  }
}
