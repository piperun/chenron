import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_content.dart";

class CardItem extends StatelessWidget {
  final FolderItem item;
  final VoidCallback? onTap;
  final bool showImage;
  final int maxTags;
  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;

  const CardItem({
    super.key,
    required this.item,
    this.onTap,
    this.showImage = true,
    this.maxTags = 5,
    this.includedTagNames = const {},
    this.excludedTagNames = const {},
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
              if (showImage &&
                  item.type == FolderItemType.link &&
                  url.isNotEmpty)
                ItemImageHeader(url: url),

              // Content section
              Padding(
                padding: EdgeInsets.all(showImage ? 12 : 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Info bar (Created + Items)
                    ItemMetaRow(item: item, url: url),
                    const SizedBox(height: 4),

                    // Title (1 line when no image)
                    ItemTitle(item: item, url: url, maxLines: showImage ? 2 : 1),
                    const SizedBox(height: 4),

                    // Description (compact when no image)
                    ItemDescription(item: item, url: url, maxLines: showImage ? 3 : 2),
                    
                    // Link + copy bar (only for links with image)
                    if (showImage && item.type == FolderItemType.link && url.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      ItemUrlBar(url: url),
                    ],

                    // Tags at bottom
                    if (ItemUtils.buildTags(item, maxTags: maxTags).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: ItemUtils.buildTags(
                          item,
                          maxTags: maxTags,
                          includedTagNames: includedTagNames,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
