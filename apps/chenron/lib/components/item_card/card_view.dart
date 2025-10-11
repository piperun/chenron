import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/item_card/item_utils.dart";
import "package:chenron/components/item_card/item_content.dart";

class ItemCardView extends StatelessWidget {
  final FolderItem item;
  final VoidCallback? onTap;

  const ItemCardView({
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
        onTap: onTap ??
            (item.type == FolderItemType.link
                ? () => ItemUtils.launchUrl(item)
                : null),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
            color: theme.cardColor,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // OG:image header for links
              if (item.type == FolderItemType.link && url.isNotEmpty)
                ItemImageHeader(url: url),

              // Content section
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Meta row
                      ItemMetaRow(item: item, url: url),
                      const SizedBox(height: 8),

                      // Title
                      ItemTitle(item: item, url: url),
                      const SizedBox(height: 6),

                      // Description (up to 3 lines in card view)
                      ItemDescription(item: item, url: url, maxLines: 3),
                      const SizedBox(height: 10),

                      // URL bar with copy button (only for links)
                      if (item.type == FolderItemType.link &&
                          url.isNotEmpty) ...[
                        ItemUrlBar(url: url),
                        const SizedBox(height: 10),
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
