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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Info bar (Created + Items)
                    ItemMetaRow(item: item, url: url),
                    const SizedBox(height: 6),

                    // Title
                    ItemTitle(item: item, url: url, maxLines: 2),
                    const SizedBox(height: 6),

                    // Description (up to 3 lines)
                    ItemDescription(item: item, url: url, maxLines: 3),
                    const SizedBox(height: 6),

                    // Link + copy bar (only for links)
                    if (item.type == FolderItemType.link && url.isNotEmpty) ...[
                      ItemUrlBar(url: url),
                      const SizedBox(height: 6),
                    ],

                    // Tags at bottom
                    if (ItemUtils.buildTags(item, maxTags: maxTags).isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: ItemUtils.buildTags(
                          item,
                          maxTags: maxTags,
                          includedTagNames: includedTagNames,
                        ),
                      ),
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
