import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_content.dart";

class RowItem extends StatelessWidget {
  final FolderItem item;
  final VoidCallback? onTap;
  final bool showImage;
  final int maxTags;
  final int titleLines;
  final int descriptionLines;
  final bool showUrlBar;
  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;

  const RowItem({
    super.key,
    required this.item,
    this.onTap,
    this.showImage = true,
    this.maxTags = 5,
    this.titleLines = 2,
    this.descriptionLines = 1,
    this.showUrlBar = true,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail image (left side) for links
              if (showImage &&
                  item.type == FolderItemType.link &&
                  url.isNotEmpty)
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
                      ItemTitle(item: item, url: url, maxLines: titleLines),
                      const SizedBox(height: 4),

                      // Description
                      ItemDescription(item: item, url: url, maxLines: descriptionLines),
                      const SizedBox(height: 8),

                      // URL bar with copy button (only for links when enabled)
                      if (showUrlBar &&
                          item.type == FolderItemType.link &&
                          url.isNotEmpty) ...[
                        ItemUrlBar(url: url),
                        const SizedBox(height: 8),
                      ],

                      // Tags
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

