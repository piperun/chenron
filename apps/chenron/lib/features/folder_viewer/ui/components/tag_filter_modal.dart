import "package:flutter/material.dart";
import "package:chenron/database/database.dart";

enum TagFilterTab { include, exclude }

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
  TagFilterTab _activeTab = TagFilterTab.include;
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
    final tokens = text.split(RegExp(r"\s+"));
    bool injected = false;
    for (final token in tokens.toList()) {
      if (token.startsWith('#') && token.length > 1) {
        final raw = token.substring(1).trim();
        if (raw.isEmpty) continue;
        final match = widget.availableTags.firstWhere(
          (t) => t.name.toLowerCase() == raw.toLowerCase(),
          orElse: () => Tag(id: '', createdAt: DateTime.now(), name: ''),
        );
        if (match.name.isNotEmpty) {
          if (!_includedTags.contains(match.name)) {
            setState(() => _includedTags.add(match.name));
          }
          injected = true;
        }
      }
    }
    if (injected) {
      final remaining = tokens
          .where((t) => !(t.startsWith('#') && t.length > 1))
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

  bool _isTagSelected(String tagName) {
    if (_activeTab == TagFilterTab.include) {
      return _includedTags.contains(tagName);
    } else {
      return _excludedTags.contains(tagName);
    }
  }

  void _toggleTag(String tagName) {
    setState(() {
      if (_activeTab == TagFilterTab.include) {
        if (_includedTags.contains(tagName)) {
          _includedTags.remove(tagName);
        } else {
          _includedTags.add(tagName);
          _excludedTags.remove(tagName);
        }
      } else {
        if (_excludedTags.contains(tagName)) {
          _excludedTags.remove(tagName);
        } else {
          _excludedTags.add(tagName);
          _includedTags.remove(tagName);
        }
      }
    });
  }

  void _applyFilters() {
    Navigator.of(context).pop((included: _includedTags, excluded: _excludedTags));
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
                          "Filter by Tags",
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Select tags to include or exclude from results",
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
                    label: "Include",
                    count: _includedTags.length,
                    isActive: _activeTab == TagFilterTab.include,
                    onTap: () => setState(() => _activeTab = TagFilterTab.include),
                  ),
                  _TabButton(
                    label: "Exclude",
                    count: _excludedTags.length,
                    isActive: _activeTab == TagFilterTab.exclude,
                    onTap: () => setState(() => _activeTab = TagFilterTab.exclude),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search tags or type #tag to include...",
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
                        final isSelected = _isTagSelected(tag.name);
                        return _TagListItem(
                          tag: tag,
                          isSelected: isSelected,
                          onTap: () => _toggleTag(tag.name),
                        );
                      },
                    ),
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

class _TagListItem extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagListItem({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
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
              child: Icon(Icons.local_offer, size: 16, color: theme.colorScheme.secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tag.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }
}
