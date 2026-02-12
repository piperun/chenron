import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_content.dart";

class CardItem extends StatefulWidget {
  final FolderItem item;
  final VoidCallback? onTap;
  final bool showImage;
  final int maxTags;
  final int titleLines;
  final int descriptionLines;
  final bool showUrlBar;
  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;

  const CardItem({
    super.key,
    required this.item,
    this.onTap,
    this.showImage = true,
    this.maxTags = 5,
    this.titleLines = 2,
    this.descriptionLines = 2,
    this.showUrlBar = true,
    this.includedTagNames = const {},
    this.excludedTagNames = const {},
  });

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  bool _tagsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = ItemUtils.getUrl(widget.item);
    final tagCount = widget.item.tags.length;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _tagsExpanded
            ? () => setState(() => _tagsExpanded = false)
            : widget.onTap ??
                (widget.item.type == FolderItemType.link
                    ? () => ItemUtils.launchUrl(widget.item)
                    : null),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
            color: theme.cardColor,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Card content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // OG:image header for links
                  if (widget.showImage &&
                      widget.item.type == FolderItemType.link &&
                      url.isNotEmpty)
                    ItemImageHeader(url: url),

                  // Content section
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(widget.showImage ? 12 : 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ItemMetaRow(item: widget.item, url: url),
                          const SizedBox(height: 4),
                          Flexible(
                            child: ItemTitle(
                                item: widget.item,
                                url: url,
                                maxLines: widget.titleLines),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: ItemDescription(
                                item: widget.item,
                                url: url,
                                maxLines: widget.descriptionLines),
                          ),
                          if (widget.showUrlBar &&
                              widget.item.type == FolderItemType.link &&
                              url.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            ItemUrlBar(url: url),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Tag badge or expanded panel
              if (tagCount > 0 && !_tagsExpanded)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _TagBadge(
                    tagCount: tagCount,
                    onTap: () => setState(() => _tagsExpanded = true),
                  ),
                ),
              if (tagCount > 0 && _tagsExpanded)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _ExpandedTagPanel(
                    item: widget.item,
                    maxTags: widget.maxTags,
                    includedTagNames: widget.includedTagNames,
                    onClose: () => setState(() => _tagsExpanded = false),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final int tagCount;
  final VoidCallback onTap;

  const _TagBadge({
    required this.tagCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tag,
              size: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 2),
            Text(
              "$tagCount",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedTagPanel extends StatelessWidget {
  final FolderItem item;
  final int maxTags;
  final Set<String> includedTagNames;
  final VoidCallback onClose;

  const _ExpandedTagPanel({
    required this.item,
    required this.maxTags,
    required this.includedTagNames,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onClose,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: theme.dividerColor),
          ),
        ),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: ItemUtils.buildTags(
            item,
            maxTags: maxTags,
            includedTagNames: includedTagNames,
          ),
        ),
      ),
    );
  }
}

