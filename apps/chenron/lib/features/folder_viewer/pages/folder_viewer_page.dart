import "package:flutter/material.dart";
import "package:chenron/features/folder_viewer/ui/components/folder_header.dart";
import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:chenron/shared/item_display/item_stats_bar.dart";
import "package:chenron/shared/item_display/item_grid_view.dart";
import "package:chenron/shared/item_display/item_list_view.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/db_result.dart" show FolderResult;
import "package:chenron/models/item.dart";
import "package:chenron/database/database.dart" show IncludeOptions, AppDataInclude, Folder;
import "package:signals/signals_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:chenron/features/viewer/state/viewer_state.dart";

class FolderViewerPage extends StatefulWidget {
  final String folderId;

  const FolderViewerPage({
    super.key,
    required this.folderId,
  });

  @override
  State<FolderViewerPage> createState() => _FolderViewerPageState();
}

class _FolderViewerPageState extends State<FolderViewerPage> {
  ViewMode _viewMode = ViewMode.grid;
  SortMode _sortMode = SortMode.nameAsc;
  Set<FolderItemType> _selectedTypes = {FolderItemType.link, FolderItemType.document, FolderItemType.folder};
  String _searchQuery = "";
  late Future<FolderResult> _folderData;
  bool _isHeaderExpanded = true;
  bool _isHeaderLocked = false;

  @override
  void initState() {
    super.initState();
    _loadLockState();
    _folderData = locator
        .get<Signal<Future<AppDatabaseHandler>>>()
        .value
        .then((db) => db.appDatabase
            .getFolder(
              folderId: widget.folderId,
              includeOptions: const IncludeOptions({AppDataInclude.items, AppDataInclude.tags}),
            )
            .then((folder) => folder!));
  }

  Future<void> _loadLockState() async {
    final prefs = await SharedPreferences.getInstance();
    final isLocked = prefs.getBool('folder_viewer_header_locked') ?? false;
    if (mounted) {
      setState(() {
        _isHeaderLocked = isLocked;
      });
    }
  }

  Future<void> _toggleHeaderLock() async {
    final newLockState = !_isHeaderLocked;
    setState(() {
      _isHeaderLocked = newLockState;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('folder_viewer_header_locked', newLockState);
  }

  List<FolderItem> _getFilteredAndSortedItems(List<FolderItem> items) {
    // Make a mutable copy of the list
    var itemsList = List<FolderItem>.from(items);
    // Apply filter - only show items whose type is in the selected types
    itemsList = itemsList.where((item) => _selectedTypes.contains(item.type)).toList();

    // Apply search
    if (_searchQuery.isNotEmpty) {
      itemsList = itemsList.where((item) {
        final query = _searchQuery.toLowerCase();
        // Search in path
        if (item.path is StringContent) {
          final pathStr = (item.path as StringContent).value.toLowerCase();
          if (pathStr.contains(query)) return true;
        }
        // TODO: Search in tags when implemented
        return false;
      }).toList();
    }

    // Apply sort
    itemsList.sort((a, b) {
      switch (_sortMode) {
        case SortMode.nameAsc:
          return _getItemName(a).compareTo(_getItemName(b));
        case SortMode.nameDesc:
          return _getItemName(b).compareTo(_getItemName(a));
        case SortMode.dateAsc:
          // TODO: Implement when date fields are available
          return 0;
        case SortMode.dateDesc:
          // TODO: Implement when date fields are available
          return 0;
      }
    });

    return itemsList;
  }

  String _getItemName(FolderItem item) {
    if (item.path is StringContent) {
      return (item.path as StringContent).value;
    }
    return "";
  }

  Map<FolderItemType, int> _getItemCounts(List<FolderItem> items) {
    final counts = <FolderItemType, int>{
      FolderItemType.link: 0,
      FolderItemType.document: 0,
      FolderItemType.folder: 0,
    };

    for (final item in items) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }

    return counts;
  }

  void _onViewModeChanged(ViewMode mode) {
    setState(() => _viewMode = mode);
  }

  void _onSortChanged(SortMode mode) {
    setState(() => _sortMode = mode);
  }

  void _onFilterChanged(Set<FolderItemType> types) {
    setState(() => _selectedTypes = types);
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  Widget _buildCollapsedHeader(Folder folder) {
    final theme = Theme.of(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.9),
            theme.colorScheme.secondary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              folder.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Lock button
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: Icon(
                _isHeaderLocked ? Icons.lock : Icons.lock_open,
                key: ValueKey<bool>(_isHeaderLocked),
                color: Colors.white,
              ),
            ),
            onPressed: () => _toggleHeaderLock(),
          ),
          Icon(
            _isHeaderExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.white.withOpacity(_isHeaderLocked ? 0.4 : 1.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<FolderResult>(
        future: _folderData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final result = snapshot.data;
          if (result == null) {
            return const Center(child: Text("Folder not found"));
          }

          final filteredItems = _getFilteredAndSortedItems(result.items);
          final itemCounts = _getItemCounts(result.items);

          return Column(
            children: [
              // Collapsible header
              GestureDetector(
                onTap: _isHeaderLocked ? null : () => setState(() => _isHeaderExpanded = !_isHeaderExpanded),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _isHeaderExpanded ? null : 60,
                  child: _isHeaderExpanded
                      ? FolderHeader(
                          folder: result.data,
                          tags: result.tags,
                          totalItems: result.items.length,
                          onBack: () => Navigator.pop(context),
                          isExpanded: _isHeaderExpanded,
                          onToggle: () => setState(() => _isHeaderExpanded = !_isHeaderExpanded),
                          isLocked: _isHeaderLocked,
                          onToggleLock: _toggleHeaderLock,
                          onTagTap: (tagName) {
                            Navigator.pop(context);
                            viewerViewModelSignal.value.searchController.text = tagName;
                          },
                        )
                      : _buildCollapsedHeader(result.data),
                ),
              ),
              ItemToolbar(
                searchQuery: _searchQuery,
                onSearchChanged: _onSearchChanged,
                selectedTypes: _selectedTypes,
                onFilterChanged: _onFilterChanged,
                sortMode: _sortMode,
                onSortChanged: _onSortChanged,
                viewMode: _viewMode,
                onViewModeChanged: _onViewModeChanged,
              ),
              ItemStatsBar(
                linkCount: itemCounts[FolderItemType.link] ?? 0,
                documentCount: itemCounts[FolderItemType.document] ?? 0,
                folderCount: itemCounts[FolderItemType.folder] ?? 0,
                selectedTypes: _selectedTypes,
                onFilterChanged: _onFilterChanged,
              ),
              Expanded(
                child: _viewMode == ViewMode.grid
                    ? ItemGridView(items: filteredItems)
                    : ItemListView(items: filteredItems),
              ),
            ],
          );
        },
      ),
    );
  }
}
