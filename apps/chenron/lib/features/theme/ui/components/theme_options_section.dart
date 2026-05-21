import "dart:async";

import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:vibe/vibe.dart";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/state/theme_settings.dart";
import "package:chenron/features/theme/state/theme_utils.dart";
import "package:chenron/locator.dart";

/// Renders the active theme's declared [VibeTheme.settings] as a list
/// of interactive tiles. Hides itself when the active theme exposes no
/// options.
class ThemeOptionsSection extends StatelessWidget {
  const ThemeOptionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeSettingsNotifier notifier =
        locator.get<SettingsCoordinator>().theme;

    return Watch((BuildContext context) {
      final ThemeSettings snapshot = notifier.current.value;
      final String? themeId = snapshot.selectedKey;
      if (themeId == null) return const SizedBox.shrink();

      final VibeTheme? theme = themeRegistry.get(themeId);
      if (theme == null || theme.settings.isEmpty) {
        return const SizedBox.shrink();
      }

      final TextTheme textTheme = Theme.of(context).textTheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              "${theme.name} options",
              style: textTheme.titleSmall,
            ),
          ),
          for (final ThemeSetting<Object?> setting in theme.settings)
            switch (setting) {
              BoolThemeSetting() => _BoolSettingTile(
                  notifier: notifier,
                  setting: setting,
                ),
              EnumThemeSetting<Enum>() => _EnumSettingTile(
                  notifier: notifier,
                  setting: setting,
                ),
            },
        ],
      );
    });
  }
}

class _BoolSettingTile extends StatelessWidget {
  const _BoolSettingTile({
    required this.notifier,
    required this.setting,
  });

  final ThemeSettingsNotifier notifier;
  final BoolThemeSetting setting;

  @override
  Widget build(BuildContext context) {
    return Watch((BuildContext context) {
      final Map<String, Object?> opts = notifier.themeOptions.value;
      final bool value =
          opts[setting.key] as bool? ?? setting.defaultValue;
      return SwitchListTile(
        title: Text(setting.label),
        subtitle: setting.description == null
            ? null
            : Text(setting.description!),
        value: value,
        onChanged: (bool newValue) {
          unawaited(notifier.setOption(setting.key, newValue));
        },
      );
    });
  }
}

class _EnumSettingTile extends StatelessWidget {
  const _EnumSettingTile({
    required this.notifier,
    required this.setting,
  });

  final ThemeSettingsNotifier notifier;
  final EnumThemeSetting<Enum> setting;

  @override
  Widget build(BuildContext context) {
    return Watch((BuildContext context) {
      final Map<String, Object?> opts = notifier.themeOptions.value;
      final Object? raw = opts[setting.key];
      // Persistence stores enums as `Enum.name`; resolve back to the
      // matching enum value, falling back to the default if the stored
      // name no longer exists (schema drift).
      final Enum selected = setting.options.firstWhere(
        (Enum option) {
          if (raw is Enum) return option == raw;
          if (raw is String) return option.name == raw;
          return false;
        },
        orElse: () => setting.defaultValue,
      );
      return ListTile(
        title: Text(setting.label),
        subtitle: setting.description == null
            ? null
            : Text(setting.description!),
        trailing: DropdownButton<Enum>(
          value: selected,
          onChanged: (Enum? newValue) {
            if (newValue == null) return;
            unawaited(notifier.setOption(setting.key, newValue));
          },
          items: [
            for (final Enum option in setting.options)
              DropdownMenuItem<Enum>(
                value: option,
                child: Text(setting.labelFor(option)),
              ),
          ],
        ),
      );
    });
  }
}
