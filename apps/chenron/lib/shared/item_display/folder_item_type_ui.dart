import "package:database/models/item.dart";
import "package:flutter/material.dart";

/// UI-side decoration for [FolderItemType].
///
/// Replaces the legacy `ItemKind` enum and the ad-hoc icon/label/color
/// maps that lived inside individual widgets. Consumers that need a
/// different icon variant (e.g. outlined for type-selector cards) can
/// still pass their own; this extension just provides the canonical
/// shorthand.
extension FolderItemTypeUi on FolderItemType {
  IconData get icon => switch (this) {
        FolderItemType.link => Icons.link,
        FolderItemType.document => Icons.description,
        FolderItemType.folder => Icons.folder,
      };

  /// Short user-facing label.
  String get label => switch (this) {
        FolderItemType.link => "Link",
        FolderItemType.document => "Doc",
        FolderItemType.folder => "Folder",
      };

  Color colorOf(ThemeData theme) => switch (this) {
        FolderItemType.link => theme.colorScheme.primary,
        FolderItemType.document => theme.colorScheme.tertiary,
        FolderItemType.folder => theme.colorScheme.secondary,
      };
}

/// Best-effort parser from a free-form string into [FolderItemType].
/// Accepts the historical aliases used in DB rows ("link", "document",
/// "doc", "folder"). Returns `null` for unrecognized input — callers
/// can supply their own fallback (icon, label, color).
extension FolderItemTypeStringParse on String {
  FolderItemType? toFolderItemType() {
    switch (toLowerCase()) {
      case "link":
        return FolderItemType.link;
      case "document":
      case "doc":
        return FolderItemType.document;
      case "folder":
        return FolderItemType.folder;
      default:
        return null;
    }
  }
}
