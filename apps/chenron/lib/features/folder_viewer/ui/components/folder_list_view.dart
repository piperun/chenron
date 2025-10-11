import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/item_card/item_card.dart";
import "package:url_launcher/url_launcher.dart";

class FolderListView extends StatelessWidget {
  final List<FolderItem> items;

  const FolderListView({
    super.key,
    required this.items,
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
            return ItemCard(
              item: item,
              mode: PreviewMode.list,
              onTap: item.type == FolderItemType.link
                  ? () => _launchUrl(item)
                  : null,
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
            "No items in this folder",
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add links, documents, or create subfolders to get started",
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

