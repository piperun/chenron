import "package:flutter/material.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/features/settings/models/settings_category.dart";
import "package:chenron/features/settings/ui/archive/archive_settings.dart";
import "package:chenron/features/settings/ui/cache/cache_settings.dart";
import "package:chenron/features/settings/ui/display/display_settings.dart";
import "package:chenron/features/settings/ui/data/data_settings.dart";
import "package:chenron/features/settings/ui/backup/backup_settings.dart";
import "package:chenron/features/settings/ui/tags/tag_management_settings.dart";
import "package:chenron/features/theme/pages/theme_settings.dart";

class SettingsContentPanel extends StatelessWidget {
  final SettingsCategory category;
  final ConfigController controller;
  final VoidCallback onSave;
  final bool isSaving;
  final bool hasUnsavedChanges;

  const SettingsContentPanel({
    super.key,
    required this.category,
    required this.controller,
    required this.onSave,
    required this.isSaving,
    required this.hasUnsavedChanges,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            category.label,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: _buildContent(category, controller),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Center(
              child: ElevatedButton(
                onPressed: isSaving || !hasUnsavedChanges ? null : onSave,
                child: const Text("Save Settings"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _buildContent(
    SettingsCategory category,
    ConfigController controller,
  ) {
    return switch (category) {
      SettingsCategory.theme => [ThemeSettingsPanel(controller: controller)],
      SettingsCategory.display => [const DisplaySettingsPanel()],
      SettingsCategory.cache => [const CacheSettings()],
      SettingsCategory.archive => [const ArchiveSettingsPanel()],
      SettingsCategory.backup => [BackupSettings(controller: controller)],
      SettingsCategory.data => [DataSettings(controller: controller)],
      SettingsCategory.tags => [const TagManagementSettings()],
      // Parent categories: show first child's content as fallback
      SettingsCategory.appearance => [ThemeSettingsPanel(controller: controller)],
    };
  }
}
