import "package:flutter/material.dart";
import "package:trina_grid/trina_grid.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron/features/create/link/renderers/link_status_renderer.dart";
import "package:chenron/components/tables/renderers/shared/tags_renderer.dart";
import "package:chenron/components/tables/renderers/shared/folders_renderer.dart";
import "package:chenron/components/tables/renderers/shared/actions_renderer.dart";

/// Builder for creating link table columns
///
/// Composes shared renderers (tags, folders, actions) with link-specific
/// renderers (status, validation) to create the complete column definition.
class LinkColumnBuilder {
  static List<TrinaColumn> build({
    required List<LinkEntry> entries,
    required ThemeData theme,
    required BuildContext context,
    required Map<String, String> folderNames,
    required Set<String> globalTags,
    required ValueChanged<Key> onEdit,
    required ValueChanged<Key> onDelete,
  }) {
    return [
      TrinaColumn(
        title: "Status",
        field: "status",
        type: TrinaColumnType.text(),
        width: 80,
        enableRowChecked: true,
        renderer: (rendererContext) {
          final entry = findEntry(entries, rendererContext.row.key);
          if (entry == null) return const SizedBox.shrink();
          return LinkStatusRenderer.build(entry, theme, context);
        },
      ),
      TrinaColumn(
        title: "URL",
        field: "url",
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: "Tags",
        field: "tags",
        type: TrinaColumnType.text(),
        width: 200,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final entry = findEntry(entries, rendererContext.row.key);
          if (entry == null) return const SizedBox.shrink();
          final merged = globalTags.isEmpty
              ? entry.tags
              : <String>{...entry.tags, ...globalTags}.toList();
          return TableTagsCell(tags: merged, theme: theme);
        },
      ),
      TrinaColumn(
        title: "Folders",
        field: "folders",
        type: TrinaColumnType.text(),
        width: 180,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final entry = findEntry(entries, rendererContext.row.key);
          if (entry == null) return const SizedBox.shrink();
          return TableFoldersCell(
            folderIds: entry.folderIds,
            folderNames: folderNames,
            theme: theme,
          );
        },
      ),
      TrinaColumn(
        title: "Archived",
        field: "archived",
        type: TrinaColumnType.text(),
        width: 80,
      ),
      TrinaColumn(
        title: "Actions",
        field: "actions",
        type: TrinaColumnType.text(),
        width: 150,
        renderer: (rendererContext) {
          final entry = findEntry(entries, rendererContext.row.key);
          if (entry == null) return const SizedBox.shrink();
          return TableActionsCell<LinkEntry>(
            item: entry,
            itemKey: entry.key,
            theme: theme,
            onEdit: onEdit,
            onDelete: onDelete,
          );
        },
      ),
    ];
  }

  /// Looks up the entry whose key matches [key].
  ///
  /// Returns null when no entry matches — a row can briefly outlive its entry
  /// (e.g. the entry was just removed) while the grid still renders the row,
  /// so callers must render a safe empty cell rather than dereferencing null.
  @visibleForTesting
  static LinkEntry? findEntry(List<LinkEntry> entries, Key key) {
    for (final entry in entries) {
      if (entry.key == key) return entry;
    }
    return null;
  }
}

