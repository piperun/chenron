import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";

// Title widget
class ItemTitle extends StatelessWidget {
  final FolderItem item;
  final String? url;
  final int maxLines;

  const ItemTitle({
    super.key,
    required this.item,
    this.url,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (item.type == FolderItemType.link && url != null && url!.isNotEmpty) {
      return FutureBuilder<Map<String, dynamic>?>(
        future: MetadataFactory.getOrFetch(url!),
        builder: (context, snapshot) {
          final title = snapshot.data?["title"] as String? ?? url!;
          return Tooltip(
            message: title,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.3,
                letterSpacing: 0,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      );
    }

    // For folders and other items, use prominent styling
    final title = ItemUtils.getItemTitle(item);
    return Tooltip(
      message: title,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: item.type == FolderItemType.folder ? 16 : 15,
          height: 1.3,
          color: item.type == FolderItemType.folder
              ? theme.colorScheme.onSurface
              : null,
          letterSpacing: item.type == FolderItemType.folder ? 0.1 : 0,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
