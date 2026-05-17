import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/unified_item.dart";

enum PreviewMode {
  card,
  list,
}

/// A single item cell.
///
/// Pure widget: all display preferences arrive as resolved primitives.
/// The parent ([ItemGridView] / [ItemListView]) reads the config signals
/// once per visible window — this keeps reactive subscriptions out of the
/// per-cell build path.
class ViewerItem extends StatelessWidget {
  final FolderItem item;
  final PreviewMode mode;
  final VoidCallback? onTap;

  final bool showImage;
  final bool showCopyLink;
  final int maxTags;
  final int titleLines;
  final int descriptionLines;

  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;
  final ValueChanged<String>? onTagFilterTap;

  const ViewerItem({
    super.key,
    required this.item,
    this.mode = PreviewMode.card,
    this.onTap,
    required this.showImage,
    required this.showCopyLink,
    required this.maxTags,
    required this.titleLines,
    required this.descriptionLines,
    this.includedTagNames = const {},
    this.excludedTagNames = const {},
    this.onTagFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return UnifiedItem(
      item: item,
      mode: mode,
      onTap: onTap,
      showImage: showImage,
      showCopyLink: showCopyLink,
      maxTags: maxTags,
      titleLines: titleLines,
      descriptionLines: descriptionLines,
      includedTagNames: includedTagNames,
      excludedTagNames: excludedTagNames,
      onTagFilterTap: onTagFilterTap,
    );
  }
}
