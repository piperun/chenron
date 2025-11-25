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
          final entry = _findEntry(entries, rendererContext.row.key);
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
          final entry = _findEntry(entries, rendererContext.row.key);
          return TagsRenderer.build(entry.tags, theme);
        },
      ),
      TrinaColumn(
        title: "Folders",
        field: "folders",
        type: TrinaColumnType.text(),
        width: 180,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final entry = _findEntry(entries, rendererContext.row.key);
          return FoldersRenderer.build(
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
          final entry = _findEntry(entries, rendererContext.row.key);
          return ActionsRenderer.build<LinkEntry>(
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

  static LinkEntry _findEntry(List<LinkEntry> entries, Key key) {
    return entries.firstWhere((e) => e.key == key);
  }
}

