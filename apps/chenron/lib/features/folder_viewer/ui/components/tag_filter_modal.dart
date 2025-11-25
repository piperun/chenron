import "package:database/database.dart";
import "package:chenron/features/folder_viewer/ui/components/tag_filter/active_filters_tab.dart";
import "package:chenron/features/folder_viewer/ui/components/tag_filter/available_tags_tab.dart";
import "package:flutter/material.dart";

enum TagFilterTab { active, available }

class TagFilterModal extends StatefulWidget {
  final List<Tag> availableTags;
  final Set<String> initialIncludedTags;
  final Set<String> initialExcludedTags;

  const TagFilterModal({
    super.key,
    required this.availableTags,
    this.initialIncludedTags = const {},
    this.initialExcludedTags = const {},
  });

  @override
  State<TagFilterModal> createState() => _TagFilterModalState();

  static Future<({Set<String> included, Set<String> excluded})?> show({
    required BuildContext context,
    required List<Tag> availableTags,
    Set<String> initialIncludedTags = const {},
    Set<String> initialExcludedTags = const {},
  }) {
    return showDialog<({Set<String> included, Set<String> excluded})>(
      context: context,
      builder: (context) => TagFilterModal(
        availableTags: availableTags,
        initialIncludedTags: initialIncludedTags,
        initialExcludedTags: initialExcludedTags,
      ),
    );
  }
}

class _TagFilterModalState extends State<TagFilterModal> {
  late Set<String> _includedTags;
  late Set<String> _excludedTags;
  TagFilterTab _activeTab = TagFilterTab.active;

  // Available tab search state
  String _availableSearchQuery = "";
  late final TextEditingController _availableSearchController;

  // Active tab search state
  late final TextEditingController _activeSearchController;

  @override
  void initState() {
    super.initState();
    _includedTags = Set.from(widget.initialIncludedTags);
    _excludedTags = Set.from(widget.initialExcludedTags);

    _availableSearchController = TextEditingController();
    _availableSearchController.addListener(_handleAvailableSearchChanged);

    _activeSearchController = TextEditingController();
  }

  void _handleAvailableSearchChanged() {
    final text = _availableSearchController.text;
    final tokens = text.split(RegExp(r"\s+"));
    bool injected = false;
    for (final token in tokens.toList()) {
      // Handle exclusion pattern: -#tag
      if (token.startsWith("-#") && token.length > 2) {
        final raw = token.substring(2).trim();
        if (raw.isEmpty) continue;
        final match = widget.availableTags.firstWhere(
          (t) => t.name.toLowerCase() == raw.toLowerCase(),
          orElse: () => Tag(id: "", createdAt: DateTime.now(), name: ""),
        );
        if (match.name.isNotEmpty) {
          if (!_excludedTags.contains(match.name)) {
            setState(() {
              _excludedTags.add(match.name);
              _includedTags.remove(match.name);
            });
          }
          injected = true;
        }
      }
      // Handle inclusion pattern: #tag
      else if (token.startsWith("#") && token.length > 1) {
        final raw = token.substring(1).trim();
        if (raw.isEmpty) continue;
        final match = widget.availableTags.firstWhere(
          (t) => t.name.toLowerCase() == raw.toLowerCase(),
          orElse: () => Tag(id: "", createdAt: DateTime.now(), name: ""),
        );
        if (match.name.isNotEmpty) {
          if (!_includedTags.contains(match.name)) {
            setState(() {
              _includedTags.add(match.name);
              _excludedTags.remove(match.name);
            });
          }
          injected = true;
        }
      }
    }
    if (injected) {
      final remaining = tokens
          .where((t) =>
              !(t.startsWith("-#") && t.length > 2) &&
              !(t.startsWith("#") && t.length > 1))
          .join(" ");
      if (remaining != text) {
        _availableSearchController
          ..text = remaining
          ..selection = TextSelection.collapsed(offset: remaining.length);
      }
    }
    setState(
        () => _availableSearchQuery = _availableSearchController.text.trim());
  }

  void _addToIncluded(String tagName) {
    setState(() {
      _includedTags.add(tagName);
      _excludedTags.remove(tagName);
    });
  }

  void _addToExcluded(String tagName) {
    setState(() {
      _excludedTags.add(tagName);
      _includedTags.remove(tagName);
    });
  }

  void _removeFromIncluded(String tagName) {
    setState(() => _includedTags.remove(tagName));
  }

  void _removeFromExcluded(String tagName) {
    setState(() => _excludedTags.remove(tagName));
  }

  void _clearAll() {
    setState(() {
      _includedTags.clear();
      _excludedTags.clear();
    });
  }

  void _applyFilters() {
    Navigator.of(context)
        .pop((included: _includedTags, excluded: _excludedTags));
  }

  @override
  void dispose() {
    _availableSearchController.dispose();
    _activeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
        height: 640,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tag Filters",
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_includedTags.length + _excludedTags.length} active filter${_includedTags.length + _excludedTags.length == 1 ? '' : 's'}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: "Close",
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  _TabButton(
                    label: "Active Filters",
                    count: _includedTags.length + _excludedTags.length,
                    isActive: _activeTab == TagFilterTab.active,
                    onTap: () =>
                        setState(() => _activeTab = TagFilterTab.active),
                  ),
                  _TabButton(
                    label: "Available Tags",
                    count: widget.availableTags.length,
                    isActive: _activeTab == TagFilterTab.available,
                    onTap: () =>
                        setState(() => _activeTab = TagFilterTab.available),
                  ),
                ],
              ),
            ),

            // Content based on active tab
            Expanded(
              child: _activeTab == TagFilterTab.active
                  ? ActiveFiltersTab(
                      includedTags: _includedTags,
                      excludedTags: _excludedTags,
                      searchController: _activeSearchController,
                      onClearAll: _clearAll,
                      onRemoveIncluded: _removeFromIncluded,
                      onRemoveExcluded: _removeFromExcluded,
                      onClearIncluded: () =>
                          setState(() => _includedTags.clear()),
                      onClearExcluded: () =>
                          setState(() => _excludedTags.clear()),
                    )
                  : AvailableTagsTab(
                      availableTags: widget.availableTags,
                      includedTags: _includedTags,
                      excludedTags: _excludedTags,
                      searchController: _availableSearchController,
                      searchQuery: _availableSearchQuery,
                      onInclude: _addToIncluded,
                      onExclude: _addToExcluded,
                      onRemove: (tagName) {
                        _removeFromIncluded(tagName);
                        _removeFromExcluded(tagName);
                      },
                    ),
            ),

            // Bottom button (applies and closes)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Apply Filters",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isActive ? theme.colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.7),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$count",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

