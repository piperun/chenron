import "package:flutter/material.dart";
import "package:chenron/features/folder_viewer/ui/components/folder_header.dart";
import "package:chenron/shared/item_display/filterable_item_display.dart";
import "package:chenron/shared/dialogs/delete_confirmation_dialog.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/folder/remove.dart";
import "package:chenron/database/extensions/link/remove.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/db_result.dart" show FolderResult;
import "package:chenron/models/item.dart";
import "package:chenron/database/database.dart" show IncludeOptions, AppDataInclude, Folder, AppDatabase;
import "package:chenron/shared/tag_filter/tag_filter_state.dart";
import "package:chenron/features/folder_editor/pages/folder_editor.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/utils/logger.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:chenron/features/shell/pages/root.dart" show globalSearchFilterSignal;

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
  late Future<FolderResult> _folderData;
  late final TagFilterState _tagFilterState;
  bool _isHeaderExpanded = true;
  bool _isHeaderLocked = false;

  @override
  void initState() {
    super.initState();
    _tagFilterState = TagFilterState();
    _loadLockState();
    _folderData = _loadFolderWithParents();
  }

  Future<FolderResult> _loadFolderWithParents() async {
    final db = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
    
    // Load the folder with its child items
    final folder = await db.appDatabase.getFolder(
      folderId: widget.folderId,
      includeOptions: const IncludeOptions({AppDataInclude.items, AppDataInclude.tags}),
    );
    
    if (folder == null) {
      throw Exception("Folder not found");
    }
    
    // Load parent folders
    final parentFolders = await _loadParentFolders(db.appDatabase);
    
    // Convert parent folders to FolderItem and combine with existing items
    final parentItems = parentFolders.map((parentFolder) => FolderItem(
      id: parentFolder.id,
      type: FolderItemType.folder,
      content: StringContent(value: parentFolder.title),
      createdAt: parentFolder.createdAt,
      tags: [], // Parent folders won't have tags in this context
    )).toList();
    
    // Combine parent items with child items
    final allItems = [...parentItems, ...folder.items];
    
    return FolderResult(
      data: folder.data,
      tags: folder.tags,
      items: allItems,
    );
  }

  Future<List<Folder>> _loadParentFolders(AppDatabase db) async {
    try {
      // Query Items table to find folders that contain this folder
      final query = db.select(db.items)
        ..where((item) => item.itemId.equals(widget.folderId));
      final results = await query.get();
      final parentFolderIds = results.map((item) => item.folderId).toList();
      
      if (parentFolderIds.isEmpty) return [];
      
      // Fetch the actual folder data for each parent ID
      final List<Folder> parentFolders = [];
      for (final parentId in parentFolderIds) {
        final folderQuery = db.select(db.folders)
          ..where((folder) => folder.id.equals(parentId));
        final folderResults = await folderQuery.get();
        if (folderResults.isNotEmpty) {
          parentFolders.add(folderResults.first);
        }
      }
      
      return parentFolders;
    } catch (e) {
      loggerGlobal.warning("FOLDER_VIEWER", "Error loading parent folders: $e");
      return [];
    }
  }

  @override
  void dispose() {
    _tagFilterState.dispose();
    super.dispose();
  }

  Future<void> _loadLockState() async {
    final prefs = await SharedPreferences.getInstance();
    final isLocked = prefs.getBool("folder_viewer_header_locked") ?? false;
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
    await prefs.setBool("folder_viewer_header_locked", newLockState);
  }

  void _handleEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderEditor(
          folderId: widget.folderId,
          hideAppBar: false,
        ),
      ),
    ).then((_) {
      // Refresh folder data after returning from editor
      if (mounted) {
        setState(() {
          _folderData = _loadFolderWithParents();
        });
      }
    });
  }

  Future<void> _handleDelete(Folder folder) async {
    // Show confirmation dialog
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      items: [
        DeletableItem(
          id: folder.id,
          title: folder.title,
          subtitle: folder.description.isNotEmpty
              ? folder.description
              : "Folder",
        ),
      ],
    );

    if (!confirmed || !mounted) return;

    // Delete folder from database
    try {
      final db = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
      final success = await db.appDatabase.removeFolder(folder.id);

      if (mounted) {
        if (success) {
          // Navigate back to viewer
          Navigator.pop(context);
          
          // Show success message on the viewer page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Folder '${folder.title}' deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to delete folder"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting folder: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteItems(List<FolderItem> itemsToDelete) async {
    if (itemsToDelete.isEmpty) return;

    // Show confirmation dialog
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      items: itemsToDelete
          .map((item) {
            // Extract title from item content
            String title = "";
            if (item.path is StringContent) {
              title = (item.path as StringContent).value;
            } else if (item.path is MapContent) {
              title = (item.path as MapContent).value["title"] ?? "";
            }
            
            return DeletableItem(
              id: item.id!,
              title: title,
              subtitle: item.type.name,
            );
          })
          .toList(),
    );

    if (!confirmed || !mounted) return;

    // Delete items from database
    try {
      final db = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
      final appDb = db.appDatabase;

      int deletedCount = 0;
      for (final item in itemsToDelete) {
        if (item.id == null) continue;
        final success = await _deleteItem(appDb, item);
        if (success) deletedCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Successfully deleted $deletedCount ${deletedCount == 1 ? 'item' : 'items'}",
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the folder data
        setState(() {
          _folderData = _loadFolderWithParents();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete items: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _deleteItem(AppDatabase db, FolderItem item) async {
    switch (item.type) {
      case FolderItemType.folder:
        return await db.removeFolder(item.id!);
      case FolderItemType.link:
        return await db.removeLink(item.id!);
      case FolderItemType.document:
        // TODO: Implement document deletion
        return false;
    }
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

          // Debug: log item tags
          loggerGlobal.fine("FOLDER_VIEWER", "${result.items.length} items, ${result.tags.length} folder tags");
          for (final item in result.items.take(3)) {
            loggerGlobal.fine("FOLDER_VIEWER", '  Item ${item.id}: ${item.tags.length} tags - ${item.tags.map((t) => t.name).join(", ")}');
          }

          return Column(
            children: [
              // Collapsible header
              GestureDetector(
                onTap: _isHeaderLocked
                    ? null
                    : () => setState(() => _isHeaderExpanded = !_isHeaderExpanded),
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
                          onToggle: () => setState(
                              () => _isHeaderExpanded = !_isHeaderExpanded),
                          isLocked: _isHeaderLocked,
                          onToggleLock: _toggleHeaderLock,
                          onTagTap: (tagName) {
                            Navigator.pop(context);
                            // Access the global search filter to add the tag
                            final searchFilter = globalSearchFilterSignal.value;
                            if (searchFilter != null) {
                              // Format as tag pattern and trigger submission
                              searchFilter.controller.value = "#$tagName";
                              // Trigger onSubmitted to parse and add the tag to filter state
                              searchFilter.controller.onSubmitted?.call("#$tagName");
                            }
                          },
                          onEdit: _handleEdit,
                          onDelete: () => _handleDelete(result.data),
                        )
                      : _buildCollapsedHeader(result.data),
                ),
              ),
              Expanded(
                child: FilterableItemDisplay(
                  items: result.items,
                  tagFilterState: _tagFilterState,
                  enableTagFiltering: true,
                  displayModeContext: "folder_viewer",
                  onDeleteRequested: _handleDeleteItems,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
