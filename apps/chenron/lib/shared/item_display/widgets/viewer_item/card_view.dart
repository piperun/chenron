import "dart:async";
import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/item_content.dart";
import "package:chenron/shared/item_detail/item_detail_dialog.dart";

class CardItem extends StatefulWidget {
  final FolderItem item;
  final VoidCallback? onTap;
  final bool showImage;
  final int maxTags;
  final int titleLines;
  final int descriptionLines;
  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;
  final ValueChanged<String>? onTagFilterTap;

  const CardItem({
    super.key,
    required this.item,
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
              // Main card content
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
                      padding: EdgeInsets.fromLTRB(
                        widget.showImage ? 12 : 8,
                        widget.showImage ? 12 : 8,
                        widget.showImage ? 12 : 8,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ItemMetaRow(item: widget.item, url: url, showInfoButton: false),
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
                        ],
                      ),
                    ),
                  ),

                  // Footer action bar
                  _CardFooter(
                    item: widget.item,
                    url: widget.item.type == FolderItemType.link
                        ? url
                        : null,
                    tagCount: tagCount,
                    onTagTap: () =>
                        setState(() => _tagsExpanded = true),
                  ),
                ],
              ),

              // Expanded tag overlay
              if (_tagsExpanded)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _ExpandedTagPanel(
                    item: widget.item,
                    maxTags: widget.maxTags,
                    includedTagNames: widget.includedTagNames,
                    onClose: () =>
                        setState(() => _tagsExpanded = false),
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
  final int tagCount;
  final VoidCallback onTagTap;

  const _CardFooter({
    required this.item,
    this.url,
    required this.tagCount,
    required this.onTagTap,
  });

  @override
  State<_CardFooter> createState() => _CardFooterState();
}

class _CardFooterState extends State<_CardFooter> {
  bool _copied = false;
  Timer? _resetTimer;

  void _handleCopy() {
    if (widget.url == null) return;
    _resetTimer?.cancel();
    ItemUtils.copyUrl(widget.url!);
    setState(() => _copied = true);
    _resetTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showCopy = widget.url != null && widget.url!.isNotEmpty;

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
              icon: _copied ? Icons.check : Icons.copy,
              label: _copied ? "Copied" : "Copy",
              tooltip: "Copy URL",
              onTap: _handleCopy,
              highlight: _copied,
            ),
          const Spacer(),
          if (widget.tagCount > 0) ...[
            _FooterChip(
              icon: Icons.sell_outlined,
              label: "${widget.tagCount}",
              tooltip:
                  "${widget.tagCount} tag${widget.tagCount == 1 ? "" : "s"}",
              onTap: widget.onTagTap,
            ),
            const SizedBox(width: 4),
          ],
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

  // Each tag chip ~28px + 6px runSpacing; derive max rows from maxTags
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

