import "package:chenron/database/database.dart";
import "package:flutter/material.dart";

class AvailableTagsTab extends StatelessWidget {
  final List<Tag> availableTags;
  final Set<String> includedTags;
  final Set<String> excludedTags;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onInclude;
  final Function(String) onExclude;
  final Function(String) onRemove;

  const AvailableTagsTab({
    super.key,
    required this.availableTags,
    required this.includedTags,
    required this.excludedTags,
    required this.searchController,
    required this.searchQuery,
    required this.onInclude,
    required this.onExclude,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter tags
    final query = searchController.text.toLowerCase().trim();
    final filteredTags = availableTags
        .where((t) => t.name.toLowerCase().contains(query))
        .toList();

    // Sort: selected first, then alphabetical
    filteredTags.sort((a, b) {
      final aSelected =
          includedTags.contains(a.name) || excludedTags.contains(a.name);
      final bSelected =
          includedTags.contains(b.name) || excludedTags.contains(b.name);
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText:
                  "Search tags or type #tag to include, -#tag to exclude...",
              prefixIcon: const Icon(Icons.search, size: 20),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),

        // Tag list
        Expanded(
          child: filteredTags.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 48,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isEmpty
                            ? "No tags available"
                            : "No matching tags",
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTags.length,
                  itemBuilder: (context, index) {
                    final tag = filteredTags[index];
                    final isIncluded = includedTags.contains(tag.name);
                    final isExcluded = excludedTags.contains(tag.name);

                    return _AvailableTagItem(
                      tag: tag,
                      isIncluded: isIncluded,
                      isExcluded: isExcluded,
                      onInclude: () => onInclude(tag.name),
                      onExclude: () => onExclude(tag.name),
                      onRemove: () {
                        if (isIncluded) onRemove(tag.name);
                        if (isExcluded) onRemove(tag.name);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AvailableTagItem extends StatelessWidget {
  final Tag tag;
  final bool isIncluded;
  final bool isExcluded;
  final VoidCallback onInclude;
  final VoidCallback onExclude;
  final VoidCallback onRemove;

  const _AvailableTagItem({
    required this.tag,
    required this.isIncluded,
    required this.isExcluded,
    required this.onInclude,
    required this.onExclude,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilter = isIncluded || isExcluded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: hasFilter
            ? (isIncluded ? Colors.green : Colors.red).withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: hasFilter
            ? Border.all(
                color: (isIncluded ? Colors.green : Colors.red)
                    .withValues(alpha: 0.3))
            : Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            hasFilter
                ? (isIncluded ? Icons.add_circle : Icons.remove_circle)
                : Icons.local_offer_outlined,
            size: 18,
            color: hasFilter
                ? (isIncluded ? Colors.green : Colors.red)
                : theme.iconTheme.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tag.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: hasFilter ? FontWeight.w600 : FontWeight.normal,
                color: hasFilter
                    ? (isIncluded ? Colors.green : Colors.red)
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          if (!hasFilter) ...[
            IconButton(
              tooltip: "Include",
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: onInclude,
            ),
            IconButton(
              tooltip: "Exclude",
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: onExclude,
            ),
          ] else ...[
            IconButton(
              tooltip: "Remove filter",
              icon: const Icon(Icons.close),
              onPressed: onRemove,
            ),
          ],
        ],
      ),
    );
  }
}
