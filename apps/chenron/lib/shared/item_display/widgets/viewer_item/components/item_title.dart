import "package:cache_manager/cache_manager.dart";
import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";

/// Title text for a [FolderItem] inside a viewer card.
///
/// For link items with an injected [metadata] signal, reactively shows
/// the fetched OG title. While loading or after failure, falls back to
/// the raw [url] so the card still has a label.
///
/// For folder items (no [metadata]), shows the static title from
/// [ItemUtils.getItemTitle].
class ItemTitle extends StatelessWidget {
  final FolderItem item;
  final String? url;
  final Signal<MetadataState>? metadata;
  final int maxLines;

  const ItemTitle({
    super.key,
    required this.item,
    this.url,
    this.metadata,
    this.maxLines = 2,
  });

  static const _maxTooltipLength = 200;

  static String _truncateTooltip(String text) {
    if (text.length <= _maxTooltipLength) return text;
    return "${text.substring(0, _maxTooltipLength)}…";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadataSignal = metadata;

    if (metadataSignal != null) {
      final fallback = url ?? "";
      return Watch((context) {
        final state = metadataSignal.value;
        final title = switch (state) {
          MetadataStateReady(:final data) => data.title ?? fallback,
          MetadataStateLoading() => fallback,
          MetadataStateFailed() => fallback,
        };
        return Tooltip(
          message: _truncateTooltip(title),
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
      });
    }

    // Folders / other non-link items: use the static title.
    final title = ItemUtils.getItemTitle(item);
    return Tooltip(
      message: _truncateTooltip(title),
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
