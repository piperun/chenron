import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/item_card/item_card.dart";
import "package:url_launcher/url_launcher.dart";

class FolderGridView extends StatelessWidget {
  final List<FolderItem> items;

  const FolderGridView({
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate optimal number of columns based on available width
            final availableWidth = constraints.maxWidth;
            final minCardWidth = 280.0;
            final spacing = 16.0;

            // Determine how many columns can fit based on width AND item count
            int columns = 1;
            if (availableWidth > minCardWidth * 2 + spacing &&
                items.length >= 2) {
              columns = 2;
            }
            if (availableWidth > minCardWidth * 3 + spacing * 2 &&
                items.length >= 3) {
              columns = 3;
            }
            if (availableWidth > minCardWidth * 4 + spacing * 3 &&
                items.length >= 4) {
              columns = 4;
            }
            if (availableWidth > minCardWidth * 5 + spacing * 4 &&
                items.length >= 5) {
              columns = 5;
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 0.85,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ItemCard(
                  item: item,
                  mode: PreviewMode.card,
                  onTap: item.type == FolderItemType.link
                      ? () => _launchUrl(item)
                      : null,
                );
              },
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
