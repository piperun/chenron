import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_content.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/viewer_item.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/components/copy_feedback_mixin.dart";
import "package:chenron/shared/item_detail/item_detail_dialog.dart";

class UnifiedItem extends StatefulWidget {
  final FolderItem item;
  final PreviewMode mode;
  final VoidCallback? onTap;
  final bool showImage;
  final int maxTags;
  final int titleLines;
  final int descriptionLines;
  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;
  final ValueChanged<String>? onTagFilterTap;

  const UnifiedItem({
    super.key,
    required this.item,
    this.mode = PreviewMode.card,
    this.onTap,
    this.showImage = true,
    this.maxTags = 5,
    this.titleLines = 2,
    this.descriptionLines = 2,
    this.includedTagNames = const {},
    this.excludedTagNames = const {},
    this.onTagFilterTap,
  });

  @override
  State<UnifiedItem> createState() => _UnifiedItemState();
}

class _UnifiedItemState extends State<UnifiedItem> {
  bool _tagsExpanded = false;

  bool get _isCard => widget.mode == PreviewMode.card;
  bool get _hasImage =>
      widget.showImage &&
      widget.item.type == FolderItemType.link &&
      ItemUtils.getUrl(widget.item).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = ItemUtils.getUrl(widget.item);

    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ItemMetaRow(item: widget.item, url: url, showInfoButton: false),
          const SizedBox(height: 4),
          ItemTitle(
              item: widget.item, url: url, maxLines: widget.titleLines),
          const SizedBox(height: 4),
          ItemDescription(
              item: widget.item, url: url, maxLines: widget.descriptionLines),
        ],
      ),
    );

    final footer = _CardFooter(
      item: widget.item,
      url: widget.item.type == FolderItemType.link ? url : null,
      maxTags: widget.maxTags,
      includedTagNames: widget.includedTagNames,
      onTagFilterTap: widget.onTagFilterTap,
      compressed: _isCard,
      onTagChipTap: () => setState(() => _tagsExpanded = true),
    );

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: _isCard ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  // Card: image on top
                  if (_isCard && _hasImage) ItemImageHeader(url: url),

                  // Card: content fills remaining space
                  // List: content in a row with thumbnail left
                  if (_isCard)
                    Expanded(child: content)
                  else
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_hasImage) ItemThumbnail(url: url),
                          Expanded(child: content),
                        ],
                      ),
                    ),

                  footer,
                ],
              ),

              // Expanded tag overlay (card compressed mode only)
              if (_tagsExpanded)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _ExpandedTagPanel(
                    item: widget.item,
                    maxTags: widget.maxTags,
                    includedTagNames: widget.includedTagNames,
                    onClose: () => setState(() => _tagsExpanded = false),
                    onTagTap: widget.onTagFilterTap,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardFooter extends StatefulWidget {
  final FolderItem item;
  final String? url;
  final int maxTags;
  final Set<String> includedTagNames;
  final ValueChanged<String>? onTagFilterTap;
  final bool compressed;
  final VoidCallback? onTagChipTap;

  const _CardFooter({
    required this.item,
    this.url,
    this.maxTags = 5,
    this.includedTagNames = const {},
    this.onTagFilterTap,
    this.compressed = false,
    this.onTagChipTap,
  });

  @override
  State<_CardFooter> createState() => _CardFooterState();
}

class _CardFooterState extends State<_CardFooter> with CopyFeedbackMixin {
  @override
  void dispose() {
    disposeCopyFeedback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showCopy = widget.url != null && widget.url!.isNotEmpty;
    final tagCount = widget.item.tags.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          if (showCopy)
            _FooterChip(
              icon: copied ? Icons.check : Icons.copy,
              label: copied ? "Copied" : "Copy",
              tooltip: "Copy URL",
              onTap: () {
                if (widget.url != null) handleCopy(widget.url!);
              },
              highlight: copied,
            ),

          // Compressed: tag count chip (card mode)
          // Expanded: inline tags (list mode)
          if (widget.compressed) ...[
            const Spacer(),
            if (tagCount > 0) ...[
              _FooterChip(
                icon: Icons.sell_outlined,
                label: "$tagCount",
                tooltip: "$tagCount tag${tagCount == 1 ? "" : "s"}",
                onTap: widget.onTagChipTap ?? () {},
              ),
              const SizedBox(width: 4),
            ],
          ] else if (tagCount > 0) ...[
            const SizedBox(width: 8),
            const SizedBox(
              height: 16,
              child: VerticalDivider(width: 1, thickness: 1),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 28,
                child: Wrap(
                  spacing: 4,
                  clipBehavior: Clip.hardEdge,
                  children: ItemUtils.buildTags(
                    widget.item,
                    maxTags: widget.maxTags,
                    includedTagNames: widget.includedTagNames,
                    onTagTap: widget.onTagFilterTap,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ] else
            const Spacer(),

          _FooterChip(
            icon: Icons.info_outline,
            label: "Details",
            tooltip: "Show details",
            onTap: () => showItemDetailDialog(
              context,
              itemId: widget.item.id!,
              itemType: widget.item.type,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onTap;
  final bool highlight;

  const _FooterChip({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = highlight
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
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
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
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
  final ValueChanged<String>? onTagTap;

  const _ExpandedTagPanel({
    required this.item,
    required this.maxTags,
    required this.includedTagNames,
    required this.onClose,
    this.onTagTap,
  });

  double get _maxWrapHeight {
    final rows = maxTags <= 1 ? 1 : (maxTags <= 5 ? 2 : 3);
    return rows * 30.0 + (rows - 1) * 6.0;
  }

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
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: _maxWrapHeight),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            clipBehavior: Clip.hardEdge,
            children: ItemUtils.buildTags(
              item,
              maxTags: maxTags,
              includedTagNames: includedTagNames,
              onTagTap: onTagTap,
              onOverflowTap: () => showItemDetailDialog(
                context,
                itemId: item.id!,
                itemType: item.type,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
