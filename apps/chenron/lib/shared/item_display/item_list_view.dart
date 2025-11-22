import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/viewer_item.dart";
import "package:url_launcher/url_launcher.dart";

class ItemListView extends StatelessWidget {
  final List<FolderItem> items;
  final DisplayMode displayMode;

  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;
  final void Function(FolderItem)? onItemTap;
  final bool isDeleteMode;
  final Set<String> selectedItemIds;

  const ItemListView({
    super.key,
    required this.items,
    this.displayMode = DisplayMode.standard,
    this.includedTagNames = const {},
    this.excludedTagNames = const {},
    this.onItemTap,
    this.isDeleteMode = false,
    this.selectedItemIds = const {},
  });

  Future<void> _launchUrl(FolderItem item) async {
    if (item.path is StringContent) {
      final url = (item.path as StringContent).value;
      if (url.isNotEmpty) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
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

    return Container(
      color: theme.brightness == Brightness.light
          ? const Color(0xFFFAFAFA)
          : theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: ListView.separated(
          shrinkWrap: false,
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = isDeleteMode &&
                item.id != null &&
                selectedItemIds.contains(item.id);

            return _SelectableItemWrapper(
              isDeleteMode: isDeleteMode,
              isSelected: isSelected,
              onTap: isDeleteMode ? () => onItemTap?.call(item) : null,
              child: ViewerItem(
                item: item,
                mode: PreviewMode.list,
                onTap: _getItemTapHandler(item),
                displayMode: displayMode,
                includedTagNames: includedTagNames,
                excludedTagNames: excludedTagNames,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SelectableItemWrapper extends StatelessWidget {
  final bool isDeleteMode;
  final bool isSelected;
  final Widget child;
  final VoidCallback? onTap;

  const _SelectableItemWrapper({
    required this.isDeleteMode,
    required this.isSelected,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDeleteMode) {
      return child;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: isDeleteMode ? onTap : null,
      child: Stack(
        children: [
          // Original item with opacity when selected
          AnimatedOpacity(
            opacity: isSelected ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: child,
          ),
          // Selection overlay
          if (isSelected)
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.onPrimary,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "SELECTED",
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
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
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No items found",
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your search or filters",
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
