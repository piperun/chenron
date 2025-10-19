import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/viewer_item.dart";
import "package:url_launcher/url_launcher.dart";

class ItemListView extends StatelessWidget {
  final List<FolderItem> items;
  final bool showImages;
  final int maxTags;
  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;
  final void Function(FolderItem)? onItemTap;

  const ItemListView({
    super.key,
    required this.items,
    this.showImages = true,
    this.maxTags = 5,
    this.includedTagNames = const {},
    this.excludedTagNames = const {},
    this.onItemTap,
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
            return ViewerItem(
              item: item,
              mode: PreviewMode.list,
              onTap: _getItemTapHandler(item),
              showImage: showImages,
              maxTags: maxTags,
              includedTagNames: includedTagNames,
              excludedTagNames: excludedTagNames,
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
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No items found",
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your search or filters",
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
