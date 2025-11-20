import "package:flutter/material.dart";

class ActiveFiltersTab extends StatefulWidget {
  final Set<String> includedTags;
  final Set<String> excludedTags;
  final TextEditingController searchController;
  final VoidCallback onClearAll;
  final Function(String) onRemoveIncluded;
  final Function(String) onRemoveExcluded;
  final VoidCallback onClearIncluded;
  final VoidCallback onClearExcluded;

  const ActiveFiltersTab({
    super.key,
    required this.includedTags,
    required this.excludedTags,
    required this.searchController,
    required this.onClearAll,
    required this.onRemoveIncluded,
    required this.onRemoveExcluded,
    required this.onClearIncluded,
    required this.onClearExcluded,
  });

  @override
  State<ActiveFiltersTab> createState() => _ActiveFiltersTabState();
}

class _ActiveFiltersTabState extends State<ActiveFiltersTab> {
  bool _includedCollapsed = false;
  bool _excludedCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final empty = widget.includedTags.isEmpty && widget.excludedTags.isEmpty;

    // Filter tags based on search
    final query = widget.searchController.text.toLowerCase().trim();
    final filteredIncluded = widget.includedTags
        .where((t) => t.toLowerCase().contains(query))
        .toList()
      ..sort();
    final filteredExcluded = widget.excludedTags
        .where((t) => t.toLowerCase().contains(query))
        .toList()
      ..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                    hintText: "Search active tags...",
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: empty ? null : widget.onClearAll,
                tooltip: "Clear all filters",
                icon: const Icon(Icons.clear_all),
                color: theme.colorScheme.error,
              ),
            ],
          ),
        ),
        Expanded(
          child: empty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.filter_alt_outlined,
                        size: 64,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No active filters",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Use Available Tags or search input",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Included section header
                    _SectionHeader(
                      leadingIcon: Icons.add_circle_outline,
                      leadingColor: Colors.green,
                      title: "Included Tags (${filteredIncluded.length})",
                      collapsed: _includedCollapsed,
                      onToggle: () => setState(
                          () => _includedCollapsed = !_includedCollapsed),
                      onClear: filteredIncluded.isEmpty
                          ? null
                          : widget.onClearIncluded,
                    ),
                    if (!_includedCollapsed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: filteredIncluded.map((tag) {
                            return _ActiveFilterChip(
                              tag: tag,
                              color: Colors.green,
                              onRemove: () => widget.onRemoveIncluded(tag),
                            );
                          }).toList(),
                        ),
                      ),

                    // Excluded section header
                    _SectionHeader(
                      leadingIcon: Icons.remove_circle_outline,
                      leadingColor: Colors.red,
                      title: "Excluded Tags (${filteredExcluded.length})",
                      collapsed: _excludedCollapsed,
                      onToggle: () => setState(
                          () => _excludedCollapsed = !_excludedCollapsed),
                      onClear: filteredExcluded.isEmpty
                          ? null
                          : widget.onClearExcluded,
                    ),
                    if (!_excludedCollapsed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: filteredExcluded.map((tag) {
                            return _ActiveFilterChip(
                              tag: tag,
                              color: Colors.red,
                              onRemove: () => widget.onRemoveExcluded(tag),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData leadingIcon;
  final Color leadingColor;
  final String title;
  final bool collapsed;
  final VoidCallback onToggle;
  final VoidCallback? onClear;

  const _SectionHeader({
    required this.leadingIcon,
    required this.leadingColor,
    required this.title,
    required this.collapsed,
    required this.onToggle,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(leadingIcon, size: 20, color: leadingColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            tooltip: collapsed ? "Expand" : "Collapse",
            icon: Icon(collapsed ? Icons.expand_more : Icons.expand_less),
            onPressed: onToggle,
          ),
          if (onClear != null)
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text("Clear"),
            ),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String tag;
  final Color color;
  final VoidCallback onRemove;

  const _ActiveFilterChip({
    required this.tag,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onRemove,
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color, width: 1),
      labelStyle: TextStyle(
        color: color.withValues(alpha: 0.9),
        fontWeight: FontWeight.w500,
      ),
      deleteIconColor: color,
    );
  }
}
