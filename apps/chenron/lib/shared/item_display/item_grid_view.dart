import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/selectable_item_wrapper.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/viewer_item.dart";
import "package:url_launcher/url_launcher.dart";

class ItemGridView extends StatelessWidget {
  final List<FolderItem> items;
  final double aspectRatio;
  final double maxCrossAxisExtent;
  final DisplayMode displayMode;

  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;
  final void Function(FolderItem)? onItemTap;
  final bool isDeleteMode;
  final Set<String> selectedItemIds;

  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  const ItemGridView({
    super.key,
    required this.items,
    this.aspectRatio = 0.72,
    this.maxCrossAxisExtent = 320,
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

  Future<void> _launchUrl(FolderItem item) async {
    final url = item.map(
      link: (linkItem) => linkItem.url,
      document: (_) => null,
      folder: (_) => null,
    );

    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  VoidCallback? _getItemTapHandler(FolderItem item) {
    if (onItemTap != null) {
      return () => onItemTap!(item);
    }
    // Default behavior: launch links
    if (item.type == FolderItemType.link) {
      return () => _launchUrl(item);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return _EmptyState();
    }

    final showLoadingCell = hasMore && onLoadMore != null;
    final totalCount = items.length + (showLoadingCell ? 1 : 0);

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
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemCount: totalCount,
          itemBuilder: (context, index) {
            if (index >= items.length) {
              return const Center(child: CircularProgressIndicator());
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
                  mode: PreviewMode.card,
                  onTap: _getItemTapHandler(item),
                  displayMode: displayMode,
                  includedTagNames: includedTagNames,
                  excludedTagNames: excludedTagNames,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No items found",
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your search or filters",
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
