import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/item_card/item_utils.dart";
import "package:chenron/components/item_card/item_content.dart";

class ItemListView extends StatelessWidget {
  final FolderItem item;
  final VoidCallback? onTap;

  const ItemListView({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = ItemUtils.getUrl(item);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap ?? (item.type == FolderItemType.link ? () => ItemUtils.launchUrl(item) : null),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
            color: theme.cardColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail image (left side) for links
              if (item.type == FolderItemType.link && url.isNotEmpty)
                ItemThumbnail(url: url),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Meta row
                      ItemMetaRow(item: item, url: url),
                      const SizedBox(height: 6),
                      
                      // Title
                      ItemTitle(item: item, url: url, maxLines: 2),
                      const SizedBox(height: 4),
                      
                      // Description (1 line in list mode)
                      ItemDescription(item: item, url: url, maxLines: 1),
                      const SizedBox(height: 8),
                      
                      // URL bar with copy button (only for links)
                      if (item.type == FolderItemType.link && url.isNotEmpty) ...[
                        ItemUrlBar(url: url),
                        const SizedBox(height: 8),
                      ],
                      
                      // Tags
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: ItemUtils.buildTags(item),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
