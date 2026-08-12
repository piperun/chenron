import "package:flutter/material.dart";

/// Settings navigation categories.
///
/// Top-level items appear in the sidebar. Items with a non-null [parent]
/// are sub-categories shown indented under their parent when expanded.
///
/// To add a new settings section:
/// 1. Add an enum value (with parent if it's a sub-category)
/// 2. Wire its content widget in SettingsContentPanel
enum SettingsCategory {
  // Top-level parents
  appearance,
  storage,
  archive,
  importExport,
  tags,
  // Sub-categories of appearance
  theme,
  display,
  // Sub-categories of storage
  database,
  cache,
  backup;

  String get label => switch (this) {
        appearance => "Appearance",
        theme => "Theme",
        display => "Display",
        storage => "Storage",
        database => "Database",
        cache => "Cache",
        backup => "Backup",
        archive => "Archive",
        importExport => "Import & Export",
        tags => "Tags",
      };

  IconData get icon => switch (this) {
        appearance => Icons.palette_outlined,
        theme => Icons.color_lens_outlined,
        display => Icons.display_settings_outlined,
        storage => Icons.folder_outlined,
        database => Icons.storage_outlined,
        cache => Icons.cached,
        backup => Icons.backup_outlined,
        archive => Icons.archive_outlined,
        importExport => Icons.import_export,
        tags => Icons.sell_outlined,
      };

  IconData get selectedIcon => switch (this) {
        appearance => Icons.palette,
        theme => Icons.color_lens,
        display => Icons.display_settings,
        storage => Icons.folder,
        database => Icons.storage,
        cache => Icons.cached,
        backup => Icons.backup,
        archive => Icons.archive,
        importExport => Icons.import_export,
        tags => Icons.sell,
      };

  /// Parent category, or null if this is top-level.
  SettingsCategory? get parent => switch (this) {
        theme || display => appearance,
        database || cache || backup => storage,
        _ => null,
      };

  /// Child sub-categories.
  List<SettingsCategory> get children => switch (this) {
        appearance => [theme, display],
        storage => [database, cache, backup],
        _ => const [],
      };

  bool get isTopLevel => parent == null;
  bool get hasChildren => children.isNotEmpty;
  bool get isLeaf => !hasChildren;

  /// Top-level categories shown in the sidebar.
  static List<SettingsCategory> get topLevel =>
      values.where((c) => c.isTopLevel).toList();

  /// Default selection: first child of first top-level, or itself.
  static SettingsCategory get defaultSelection => topLevel.first.hasChildren
      ? topLevel.first.children.first
      : topLevel.first;
}
