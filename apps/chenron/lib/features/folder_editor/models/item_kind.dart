import "package:flutter/material.dart";

enum ItemKind {
  link(Icons.link, "Link"),
  document(Icons.description, "Doc"),
  folder(Icons.folder, "Folder"),
  unknown(Icons.help_outline, null);

  final IconData icon;
  final String? label;
  const ItemKind(this.icon, this.label);

  Color colorOf(ThemeData theme) {
    switch (this) {
      case ItemKind.link:
        return theme.colorScheme.primary;
      case ItemKind.document:
        return theme.colorScheme.tertiary;
      case ItemKind.folder:
        return theme.colorScheme.secondary;
      case ItemKind.unknown:
        return theme.colorScheme.outline;
    }
  }
}

extension ParseItemKind on String {
  ItemKind toItemKind() {
    switch (toLowerCase()) {
      case "link":
        return ItemKind.link;
      case "document":
      case "doc":
        return ItemKind.document;
      case "folder":
        return ItemKind.folder;
      default:
        return ItemKind.unknown;
    }
  }
}
