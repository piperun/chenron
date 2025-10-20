import "package:flutter/material.dart";
import "package:chenron/database/database.dart";

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
  String _searchQuery = "";
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _includedTags = Set.from(widget.initialIncludedTags);
    _excludedTags = Set.from(widget.initialExcludedTags);
    _searchController = TextEditingController();
    _searchController.addListener(_handleSearchChanged);
    
    // Debug: print available tags
    print('TAG MODAL DEBUG: ${widget.availableTags.length} available tags');
    print('  Tags: ${widget.availableTags.map((t) => t.name).join(", ")}');
  }

  void _handleSearchChanged() {
    final text = _searchController.text;
    final tokens = text.split(RegExp(r"\\s+"));
    bool injected = false;
    for (final token in tokens.toList()) {
      // Handle exclusion pattern: -#tag
      if (token.startsWith('-#') && token.length > 2) {
        final raw = token.substring(2).trim();
        if (raw.isEmpty) continue;
        final match = widget.availableTags.firstWhere(
          (t) => t.name.toLowerCase() == raw.toLowerCase(),
          orElse: () => Tag(id: '', createdAt: DateTime.now(), name: ''),
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
      else if (token.startsWith('#') && token.length > 1) {
        final raw = token.substring(1).trim();
        if (raw.isEmpty) continue;
        final match = widget.availableTags.firstWhere(
          (t) => t.name.toLowerCase() == raw.toLowerCase(),
          orElse: () => Tag(id: '', createdAt: DateTime.now(), name: ''),
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
          .where((t) => !(t.startsWith('-#') && t.length > 2) && !(t.startsWith('#') && t.length > 1))
          .join(' ');
      if (remaining != text) {
        _searchController
          ..text = remaining
          ..selection = TextSelection.collapsed(offset: remaining.length);
      }
    }
    setState(() => _searchQuery = _searchController.text);
  }

  List<Tag> get _filteredTags {
    var tags = widget.availableTags;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      tags = tags.where((tag) => tag.name.toLowerCase().contains(query)).toList();
    }
    tags.sort((a, b) => a.name.compareTo(b.name));
    return tags;
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

  Widget _buildActiveFiltersTab(ThemeData theme) {
    if (_includedTags.isEmpty && _excludedTags.isEmpty) {
      return Center(
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
              "Type #tag in search or use Available Tags",
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_includedTags.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.add_circle_outline, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                "Included Tags (${_includedTags.length})",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _includedTags.clear()),
                icon: Icon(Icons.clear_all, size: 16),
                label: Text("Clear"),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _includedTags.map((tag) {
              return _ActiveFilterChip(
                tag: tag,
                color: Colors.green,
                onRemove: () => _removeFromIncluded(tag),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (_excludedTags.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.remove_circle_outline, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                "Excluded Tags (${_excludedTags.length})",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _excludedTags.clear()),
                icon: Icon(Icons.clear_all, size: 16),
                label: Text("Clear"),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _excludedTags.map((tag) {
              return _ActiveFilterChip(
                tag: tag,
                color: Colors.red,
                onRemove: () => _removeFromExcluded(tag),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAvailableTagsTab(ThemeData theme) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search tags or type #tag to include, -#tag to exclude...",
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
          child: _filteredTags.isEmpty
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
                        _searchQuery.isEmpty ? "No tags available" : "No matching tags",
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredTags.length,
                  itemBuilder: (context, index) {
                    final tag = _filteredTags[index];
                    final isIncluded = _includedTags.contains(tag.name);
                    final isExcluded = _excludedTags.contains(tag.name);
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
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480,
        height: 600,
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

            // Bottom button
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
      deleteIcon: Icon(Icons.close, size: 18),
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
    
    return InkWell(
      onTap: hasFilter ? onRemove : onInclude,
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
            if (isIncluded)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Included',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            if (isExcluded)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove_circle, size: 14, color: Colors.red),
                    SizedBox(width: 4),
                    Text(
                      'Excluded',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            if (!hasFilter)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 20),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'include',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, size: 18, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Include'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'exclude',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Exclude'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'include') {
                    onInclude();
                  } else if (value == 'exclude') {
                    onExclude();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
