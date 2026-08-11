import "dart:async";

import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:database/models/item.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/item_empty_state.dart";
import "package:chenron/shared/item_display/widgets/selectable_item_wrapper.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/viewer_item.dart";
import "package:chenron/shared/item_display/item_viewport_source.dart";

class ItemGridView extends StatelessWidget {
  final ItemViewportSource source;
  final double aspectRatio;
  final double maxCrossAxisExtent;
  final DisplayMode displayMode;

  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;
  final void Function(FolderItem)? onItemTap;
  final ValueChanged<String>? onTagFilterTap;
  final ValueChanged<FolderItem>? onItemMaterialized;
  final bool isDeleteMode;
  final Set<String> selectedItemIds;
  final bool Function(FolderItem item)? isItemSelected;

  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  const ItemGridView({
    super.key,
    required this.source,
    this.aspectRatio = 0.72,
    this.maxCrossAxisExtent = 320,
    this.displayMode = DisplayMode.standard,
    this.includedTagNames = const {},
    this.excludedTagNames = const {},
    this.onItemTap,
    this.onTagFilterTap,
    this.onItemMaterialized,
    this.isDeleteMode = false,
    this.selectedItemIds = const {},
    this.isItemSelected,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayNotifier = locator.get<SettingsCoordinator>().display;

    if (source.length == 0) {
      return const ItemEmptyState();
    }

    final showLoadingCell = hasMore && onLoadMore != null;
    final totalCount = source.length + (showLoadingCell ? 1 : 0);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(24),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (onLoadMore != null &&
              hasMore &&
              !isLoadingMore &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            onLoadMore!();
          }
          return false;
        },
        child: SignalBuilder(builder: (context) {
          // Read config preferences once per config change. Resolved values
          // are then passed as primitives to each cell — no per-cell Watch.
          final snapshot = displayNotifier.current.value;
          final showImages = snapshot.showImages;
          final showDescription = snapshot.showDescription;
          final showTags = snapshot.showTags;
          final showCopyLink = snapshot.showCopyLink;

          final titleLines = displayMode.titleLines;
          final descriptionLines =
              showDescription ? displayMode.descriptionLines : 0;
          final maxTags = showTags ? displayMode.maxTags : 0;
          final showImage = showImages && displayMode.showImage;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCrossAxisExtent,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: aspectRatio,
            ),
            itemCount: totalCount,
            itemBuilder: (context, index) {
              if (index >= source.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final item = source.itemAt(index);
              if (item == null) {
                final itemError = source.errorAt(index);
                if (itemError != null) {
                  return Center(
                    child: OutlinedButton.icon(
                      key: ValueKey("item-viewport-retry-$index"),
                      onPressed: () => unawaited(source.retryAt(index)),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                    ),
                  );
                }
                return Semantics(
                  label: "Loading item",
                  child: DecoratedBox(
                    key: ValueKey("item-viewport-loading-$index"),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
              onItemMaterialized?.call(item);
              final isSelected = isDeleteMode &&
                  item.id != null &&
                  (isItemSelected?.call(item) ??
                      selectedItemIds.contains(item.id));

              return RepaintBoundary(
                key: ValueKey(item.id ?? index),
                child: SelectableItemWrapper(
                  isDeleteMode: isDeleteMode,
                  isSelected: isSelected,
                  onTap: isDeleteMode ? () => onItemTap?.call(item) : null,
                  child: ViewerItem(
                    item: item,
                    mode: PreviewMode.card,
                    onTap: onItemTap != null ? () => onItemTap!(item) : null,
                    showImage: showImage,
                    showCopyLink: showCopyLink,
                    maxTags: maxTags,
                    titleLines: titleLines,
                    descriptionLines: descriptionLines,
                    includedTagNames: includedTagNames,
                    excludedTagNames: excludedTagNames,
                    onTagFilterTap: onTagFilterTap,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
