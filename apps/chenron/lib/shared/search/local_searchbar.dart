import "package:flutter/material.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/shared/search/search_features.dart";
import "package:chenron/shared/search/search_history.dart";

/// A simple searchbar for local filtering (e.g., filtering items in a list)
///
/// Now uses SearchFilter which manages features and filtering logic.
///
/// Example:
/// ```dart
/// final filter = SearchFilter(
///   features: const SearchFeatures({SearchFeature.debounce}),
/// );
///
/// LocalSearchBar(filter: filter)
/// ```
class LocalSearchBar extends StatelessWidget {
  final SearchFilter filter;
  final String hintText;
  final void Function(String)? onSubmitted;

  const LocalSearchBar({
    super.key,
    required this.filter,
    this.hintText = "Search by name, URL, tags...",
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHistory = filter.hasFeature(SearchFeature.history);

    return Flexible(
      flex: 2,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 250,
          maxWidth: 400,
        ),
        child: TextField(
          controller: filter.controller.textController,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: hasHistory
                ? Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.history, size: 20),
                      onPressed: () => _showHistory(context),
                      tooltip: "Search history",
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Future<void> _showHistory(BuildContext context) async {
    final history = await filter.loadHistory();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => _HistoryModal(
        history: history,
        onItemSelected: (item) {
          // Fill the search field with selected item's title
          filter.controller.textController.text = item.title;
          Navigator.pop(context);
        },
        onClear: () async {
          await filter.clearHistory();
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

/// Modal bottom sheet displaying search history
class _HistoryModal extends StatelessWidget {
  final List<SearchHistoryItem> history;
  final void Function(SearchHistoryItem) onItemSelected;
  final Future<void> Function() onClear;

  const _HistoryModal({
    required this.history,
    required this.onItemSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Searches",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (history.isNotEmpty)
                  TextButton(
                    onPressed: onClear,
                    child: const Text("Clear All"),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // History items
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No recent searches",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return ListTile(
                    leading: Icon(
                      _getIconForType(item.type),
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _formatTimestamp(item.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    trailing: Icon(
                      Icons.north_west,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    onTap: () => onItemSelected(item),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case "folder":
        return Icons.folder;
      case "link":
        return Icons.link;
      case "tag":
        return Icons.tag;
      default:
        return Icons.search;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return "$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago";
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return "$hours ${hours == 1 ? 'hour' : 'hours'} ago";
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return "$days ${days == 1 ? 'day' : 'days'} ago";
    } else {
      return "${timestamp.month}/${timestamp.day}/${timestamp.year}";
    }
  }
}

