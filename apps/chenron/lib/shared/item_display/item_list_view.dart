import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:database/models/item.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/item_empty_state.dart";
import "package:chenron/shared/item_display/widgets/selectable_item_wrapper.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/viewer_item.dart";

class ItemListView extends StatelessWidget {
  final List<FolderItem> items;
  final DisplayMode displayMode;

  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;
  final void Function(FolderItem)? onItemTap;
  final bool isDeleteMode;
  final Set<String> selectedItemIds;

  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  const ItemListView({
    super.key,
    required this.items,
    this.displayMode = DisplayMode.standard,
    this.includedTagNames = const {},
    this.excludedTagNames = const {},
    this.onItemTap,
    this.isDeleteMode = false,
    this.selectedItemIds = const {},
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayNotifier = locator.get<SettingsCoordinator>().display;

    if (items.isEmpty) {
      return const ItemEmptyState();
    }

    final showLoadingItem = hasMore && onLoadMore != null;
    final totalCount = items.length + (showLoadingItem ? 1 : 0);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
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
          child: Watch((context) {
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

            return ListView.separated(
              shrinkWrap: false,
              itemCount: totalCount,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final item = items[index];
                final isSelected = isDeleteMode &&
                    item.id != null &&
                    selectedItemIds.contains(item.id);

                return RepaintBoundary(
                  key: ValueKey(item.id ?? index),
                  child: SelectableItemWrapper(
                    isDeleteMode: isDeleteMode,
                    isSelected: isSelected,
                    onTap: isDeleteMode ? () => onItemTap?.call(item) : null,
                    child: ViewerItem(
                      item: item,
                      mode: PreviewMode.list,
                      onTap: onItemTap != null ? () => onItemTap!(item) : null,
                      showImage: showImage,
                      showCopyLink: showCopyLink,
                      maxTags: maxTags,
                      titleLines: titleLines,
                      descriptionLines: descriptionLines,
                      includedTagNames: includedTagNames,
                      excludedTagNames: excludedTagNames,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
