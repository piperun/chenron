import 'dart:convert';

import 'package:chenron/database/extensions/user_config/read.dart';
import 'package:chenron/database/extensions/user_config/update.dart';
import 'package:flutter/material.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/models/user_config.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserConfigModel>(
      future: _loadUserConfig(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return SettingsContent(userConfig: snapshot.data!);
        } else {
          return const Center(child: Text('No user config found'));
        }
      },
    );
  }

  Future<UserConfigModel> _loadUserConfig(BuildContext context) async {
    final database = Provider.of<ConfigDatabase>(context, listen: false);
    final config = await database.getUserConfig();
    return UserConfigModel(
        id: config?.id,
        darkMode: config?.darkMode,
        colorScheme: Map.castFrom(json.decode(config?.colorScheme ?? '{}')),
        archiveOrgS3AccessKey: config?.archiveOrgS3AccessKey,
        archiveOrgS3SecretKey: config?.archiveOrgS3SecretKey);
  }
}

class SettingsContent extends StatefulWidget {
  final UserConfigModel userConfig;

  const SettingsContent({super.key, required this.userConfig});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  late bool _isDarkMode;
  late Color _primaryColor;
  late TextEditingController _accessKeyController;
  late TextEditingController _secretKeyController;

  @override
  void initState() {
    super.initState();
    if (widget.userConfig.darkMode != null) {
      _isDarkMode = widget.userConfig.darkMode!;
    } else {
      _isDarkMode = false;
    }
    _primaryColor = widget.userConfig.colorScheme?['primary'] != null
        ? Color(widget.userConfig.colorScheme!['primary'])
        : Colors.blue;
    _accessKeyController = TextEditingController(
        text: widget.userConfig.archiveOrgS3AccessKey ?? '');
    _secretKeyController = TextEditingController(
        text: widget.userConfig.archiveOrgS3SecretKey ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: _primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Appearance'),
              DarkModeSwitch(
                isDarkMode: _isDarkMode,
                onChanged: (value) => setState(() => _isDarkMode = value),
              ),
              ColorPickerTile(
                primaryColor: _primaryColor,
                onColorChanged: (color) =>
                    setState(() => _primaryColor = color),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Archive.org Credentials'),
              CredentialTextField(
                  controller: _accessKeyController, label: 'Access Key'),
              CredentialTextField(
                  controller: _secretKeyController,
                  label: 'Secret Key',
                  isPassword: true),
              const SizedBox(height: 24),
              SaveSettingsButton(
                primaryColor: _primaryColor,
                onPressed: _updateUserConfig,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _updateUserConfig() {
    final database = Provider.of<ConfigDatabase>(context, listen: false);
    if (widget.userConfig.id != null) {
      database.updateUserConfig(
        id: widget.userConfig.id!,
        darkMode: _isDarkMode,
        colorScheme: json.encode({"primary": _primaryColor.value}),
        archiveOrgS3AccessKey: _accessKeyController.text,
        archiveOrgS3SecretKey: _secretKeyController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
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
      title: const Text('Dark Mode'),
      value: isDarkMode,
      onChanged: onChanged,
      secondary: const Icon(Icons.brightness_4),
    );
  }
}

class ColorPickerTile extends StatelessWidget {
  final Color primaryColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerTile(
      {super.key, required this.primaryColor, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Primary Color'),
      trailing: CircleAvatar(
        backgroundColor: primaryColor,
        radius: 15,
      ),
      onTap: () => _showColorPicker(context),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: primaryColor,
              onColorChanged: onColorChanged,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class CredentialTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;

  const CredentialTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
        ),
      ),
    );
  }
}

class SaveSettingsButton extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onPressed;

  const SaveSettingsButton(
      {super.key, required this.primaryColor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        child: const Text('Save Settings'),
      ),
    );
  }
}
