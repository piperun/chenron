import "package:chenron/pages/settings/settings_page.dart";
import 'package:flutter/material.dart';
import 'package:chenron/models/user_config.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class GeneralSettings extends StatefulWidget {
  final UserConfigModel userConfig;
  final ValueChanged<Color> onColorChanged;

  const GeneralSettings({
    super.key,
    required this.userConfig,
    required this.onColorChanged,
  });

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  late bool _isDarkMode;
  late Color _primaryColor;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.userConfig.darkMode ?? false;
    _primaryColor = widget.userConfig.colorScheme?["primary"] != null
        ? Color(widget.userConfig.colorScheme!["primary"])
        : Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DarkModeSwitch(
              isDarkMode: _isDarkMode,
              onChanged: (value) => setState(() => _isDarkMode = value),
            ),
            ColorPickerTile(
              primaryColor: _primaryColor,
              onColorChanged: (color) {
                setState(() => _primaryColor = color);
                widget.onColorChanged(color);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DarkModeSwitch extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  const DarkModeSwitch(
      {super.key, required this.isDarkMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text("Dark Mode"),
      value: isDarkMode,
      onChanged: onChanged,
      secondary: const Icon(Icons.brightness_4),
    );
  }
}
