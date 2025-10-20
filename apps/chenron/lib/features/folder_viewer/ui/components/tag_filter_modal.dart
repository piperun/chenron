import "package:flutter/material.dart";
import "package:chenron/database/database.dart";

enum TagFilterTab { active, available }

enum BulkMode { include, exclude }

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

  // Available tab search and bulk state
  String _availableSearchQuery = "";
  late final TextEditingController _availableSearchController;
  bool _bulkEnabled = false;
  BulkMode _bulkMode = BulkMode.include;
  final Set<String> _selectedForBulk = <String>{};

  // Active tab search and collapse state
  String _activeSearchQuery = "";
  late final TextEditingController _activeSearchController;
  bool _includedCollapsed = false;
  bool _excludedCollapsed = false;

  @override
  void initState() {
    super.initState();
    _includedTags = Set.from(widget.initialIncludedTags);
    _excludedTags = Set.from(widget.initialExcludedTags);

    _availableSearchController = TextEditingController();
    _availableSearchController.addListener(_handleAvailableSearchChanged);

    _activeSearchController = TextEditingController();
    _activeSearchController.addListener(() {
      setState(() => _activeSearchQuery = _activeSearchController.text.trim());
    });

    // Debug: print available tags
    // ignore: avoid_print
    print("TAG MODAL DEBUG: ${widget.availableTags.length} available tags");
    // ignore: avoid_print
    print('  Tags: ${widget.availableTags.map((t) => t.name).join(", ")}');
  }

  void _handleAvailableSearchChanged() {
    final text = _availableSearchController.text;
    final tokens = text.split(RegExp(r"\\s+"));
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
          .where((t) => !(t.startsWith("-#") && t.length > 2) && !(t.startsWith("#") && t.length > 1))
          .join(" ");
      if (remaining != text) {
        _availableSearchController
          ..text = remaining
          ..selection = TextSelection.collapsed(offset: remaining.length);
      }
    }
    setState(() => _availableSearchQuery = _availableSearchController.text.trim());
  }

  List<Tag> get _filteredAvailableTags {
    var tags = widget.availableTags;
    if (_availableSearchQuery.isNotEmpty) {
      final query = _availableSearchQuery.toLowerCase();
      tags = tags.where((tag) => tag.name.toLowerCase().contains(query)).toList();
    }
    tags.sort((a, b) => a.name.compareTo(b.name));
    return tags;
  }

  Iterable<String> get _filteredIncludedNames {
    final list = _includedTags.where((t) =>
        _activeSearchQuery.isEmpty || t.toLowerCase().contains(_activeSearchQuery.toLowerCase()));
    final sorted = list.toList()..sort((a, b) => a.compareTo(b));
    return sorted;
  }

  Iterable<String> get _filteredExcludedNames {
    final list = _excludedTags.where((t) =>
        _activeSearchQuery.isEmpty || t.toLowerCase().contains(_activeSearchQuery.toLowerCase()));
    final sorted = list.toList()..sort((a, b) => a.compareTo(b));
    return sorted;
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
    Navigator.of(context).pop((included: _includedTags, excluded: _excludedTags));
  }

  void _toggleBulk() {
    setState(() {
      _bulkEnabled = !_bulkEnabled;
      _selectedForBulk.clear();
    });
  }

  void _applyBulk() {
    if (_selectedForBulk.isEmpty) return;
    setState(() {
      if (_bulkMode == BulkMode.include) {
        _includedTags.addAll(_selectedForBulk);
        _excludedTags.removeAll(_selectedForBulk);
      } else {
        _excludedTags.addAll(_selectedForBulk);
        _includedTags.removeAll(_selectedForBulk);
      }
      _selectedForBulk.clear();
    });
  }

  Widget _buildActiveFiltersTab(ThemeData theme) {
    final empty = _includedTags.isEmpty && _excludedTags.isEmpty;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _activeSearchController,
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
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
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No active filters",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Use Available Tags or search input",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
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
                      title: "Included Tags (${_filteredIncludedNames.length})",
                      collapsed: _includedCollapsed,
                      onToggle: () => setState(() => _includedCollapsed = !_includedCollapsed),
                      onClear: _filteredIncludedNames.isEmpty
                          ? null
                          : () => setState(() => _includedTags.clear()),
                    ),
                    if (!_includedCollapsed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _filteredIncludedNames.map((tag) {
                            return _ActiveFilterChip(
                              tag: tag,
                              color: Colors.green,
                              onRemove: () => _removeFromIncluded(tag),
                            );
                          }).toList(),
                        ),
                      ),

                    // Excluded section header
                    _SectionHeader(
                      leadingIcon: Icons.remove_circle_outline,
                      leadingColor: Colors.red,
                      title: "Excluded Tags (${_filteredExcludedNames.length})",
                      collapsed: _excludedCollapsed,
                      onToggle: () => setState(() => _excludedCollapsed = !_excludedCollapsed),
                      onClear: _filteredExcludedNames.isEmpty
                          ? null
                          : () => setState(() => _excludedTags.clear()),
                    ),
                    if (!_excludedCollapsed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _filteredExcludedNames.map((tag) {
                            return _ActiveFilterChip(
                              tag: tag,
                              color: Colors.red,
                              onRemove: () => _removeFromExcluded(tag),
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

  Widget _buildAvailableTagsTab(ThemeData theme) {
    return Column(
      children: [
        // Controls row: bulk toggle and (when bulk) mode selector
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: const Text("Bulk mode"),
                selected: _bulkEnabled,
                onSelected: (_) => _toggleBulk(),
              ),
              if (_bulkEnabled)
                SegmentedButton<BulkMode>(
                  segments: const [
                    ButtonSegment(value: BulkMode.include, label: Text("Include"), icon: Icon(Icons.add_circle_outline)),
                    ButtonSegment(value: BulkMode.exclude, label: Text("Exclude"), icon: Icon(Icons.remove_circle_outline)),
                  ],
                  selected: <BulkMode>{_bulkMode},
                  onSelectionChanged: (set) => setState(() => _bulkMode = set.first),
                ),
              if (_bulkEnabled)
                TextButton(
                  onPressed: _selectedForBulk.isEmpty
                      ? null
                      : () => setState(() => _selectedForBulk.clear()),
                  child: const Text("Clear"),
                ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _availableSearchController,
            decoration: InputDecoration(
              hintText: _bulkEnabled
                  ? "Search tags (select multiple)"
                  : "Search tags or type #tag to include, -#tag to exclude...",
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),

        // Tag list
        Expanded(
          child: _filteredAvailableTags.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 48,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _availableSearchQuery.isEmpty ? "No tags available" : "No matching tags",
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredAvailableTags.length,
                  itemBuilder: (context, index) {
                    final tag = _filteredAvailableTags[index];
                    final isIncluded = _includedTags.contains(tag.name);
                    final isExcluded = _excludedTags.contains(tag.name);
                    final selected = _selectedForBulk.contains(tag.name);

                    if (_bulkEnabled) {
                      return _BulkTagItem(
                        tag: tag,
                        selected: selected,
                        onToggleSelected: () {
                          setState(() {
                            if (selected) {
                              _selectedForBulk.remove(tag.name);
                            } else {
                              _selectedForBulk.add(tag.name);
                            }
                          });
                        },
                      );
                    }

                    return _AvailableTagItem(
                      tag: tag,
                      isIncluded: isIncluded,
                      isExcluded: isExcluded,
                      onInclude: () => _addToIncluded(tag.name),
                      onExclude: () => _addToExcluded(tag.name),
                      onRemove: () {
                        if (isIncluded) _removeFromIncluded(tag.name);
                        if (isExcluded) _removeFromExcluded(tag.name);
                      },
                    );
                  },
                ),
        ),

        // Bulk footer action
        if (_bulkEnabled)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedForBulk.isEmpty ? null : _applyBulk,
                    icon: Icon(
                      _bulkMode == BulkMode.include ? Icons.add_circle : Icons.remove_circle,
                    ),
                    label: Text(
                      _bulkMode == BulkMode.include
                          ? "Add ${_selectedForBulk.length} to Included"
                          : "Add ${_selectedForBulk.length} to Excluded",
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
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
              color: Colors.black.withOpacity(0.3),
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
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_includedTags.length + _excludedTags.length} active filter${_includedTags.length + _excludedTags.length == 1 ? '' : 's'}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
                    onTap: () => setState(() => _activeTab = TagFilterTab.active),
                  ),
                  _TabButton(
                    label: "Available Tags",
                    count: widget.availableTags.length,
                    isActive: _activeTab == TagFilterTab.available,
                    onTap: () => setState(() => _activeTab = TagFilterTab.available),
                  ),
                ],
              ),
            ),

            // Content based on active tab
            Expanded(
              child: _activeTab == TagFilterTab.active
                  ? _buildActiveFiltersTab(theme)
                  : _buildAvailableTagsTab(theme),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                color: isActive ? theme.colorScheme.primary : Colors.transparent,
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
                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
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
    final theme = Theme.of(context);
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
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color, width: 1),
      labelStyle: TextStyle(
        color: color.withOpacity(0.9),
        fontWeight: FontWeight.w500,
      ),
      deleteIconColor: color,
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
            ? (isIncluded ? Colors.green : Colors.red).withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: hasFilter
            ? Border.all(
                color: (isIncluded ? Colors.green : Colors.red).withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_offer,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tag.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: hasFilter ? FontWeight.w600 : FontWeight.w500,
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

class _BulkTagItem extends StatelessWidget {
  final Tag tag;
  final bool selected;
  final VoidCallback onToggleSelected;

  const _BulkTagItem({
    required this.tag,
    required this.selected,
    required this.onToggleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onToggleSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Checkbox(value: selected, onChanged: (_) => onToggleSelected()),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tag.name,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
