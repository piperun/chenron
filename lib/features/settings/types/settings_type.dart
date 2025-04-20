import "package:flutter/material.dart" show ColorScheme, TextEditingController;

typedef ArchiveOrgControllers = ({
  TextEditingController accessKeyController,
  TextEditingController secretKeyController
});

class SettingsData {
  ArchiveOrgControllers archiveOrgControllers;
  ColorScheme? colorScheme;
  bool archiveEnabled;
  SettingsData({
    required this.archiveOrgControllers,
    this.colorScheme,
    this.archiveEnabled = false,
  });
}
