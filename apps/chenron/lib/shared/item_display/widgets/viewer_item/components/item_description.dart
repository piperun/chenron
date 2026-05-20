import "package:cache_manager/cache_manager.dart";
import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/shared/item_display/widgets/viewer_item/item_utils.dart";

/// Description / subtitle text for a [FolderItem] inside a viewer card.
///
/// For link items with an injected [metadata] signal, reactively shows
/// the fetched OG description. While loading or after failure, renders
/// nothing — current UX intentionally hides the line until real data
/// arrives.
///
/// For non-link items (no [metadata]), shows the static subtitle from
/// [ItemUtils.getItemSubtitle].
class ItemDescription extends StatelessWidget {
  final FolderItem item;
  final String? url;
  final Signal<MetadataState>? metadata;
  final int maxLines;

  const ItemDescription({
    super.key,
    required this.item,
    this.url,
    this.metadata,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadataSignal = metadata;

    if (metadataSignal != null) {
      return Watch((context) {
        final state = metadataSignal.value;
        final description = switch (state) {
          MetadataStateReady(:final data) => data.description,
          MetadataStateLoading() => null,
          MetadataStateFailed() => null,
        };
        if (description != null && description.isNotEmpty) {
          return Text(
            description,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            softWrap: true,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          );
        }
        return const SizedBox.shrink();
      });
    }

    return Text(
      ItemUtils.getItemSubtitle(item),
      style: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
