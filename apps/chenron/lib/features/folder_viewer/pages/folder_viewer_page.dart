import "package:database/main.dart";
import "package:database/database.dart";
import "package:flutter/material.dart";
import "dart:async";
import "package:signals/signals_flutter.dart";
import "package:chenron/shared/constants/durations.dart";
import "package:chenron/features/folder_viewer/ui/components/folder_header.dart";
import "package:chenron/features/folder_viewer/ui/components/collapsed_header.dart";
import "package:chenron/shared/item_display/filterable_item_display.dart";
import "package:chenron/shared/dialogs/delete_confirmation_dialog.dart";
import "package:chenron/features/folder_viewer/services/folder_viewer_service.dart";
import "package:chenron/shared/infinite_scroll/infinite_scroll_state.dart";

import "package:chenron/shared/tag_filter/tag_filter_state.dart";
import "package:chenron/features/folder_editor/pages/folder_editor.dart";
import "package:app_logger/app_logger.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:chenron/features/shell/pages/root.dart";
import "package:chenron/shared/viewer/item_handler.dart";

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
  final _service = FolderViewerService();
  late Future<FolderResult> _metadata;
  late final InfiniteScrollState<FolderItem> _infiniteScroll;
  late final TagFilterState _tagFilterState;
  bool _isHeaderExpanded = true;
  bool _isHeaderLocked = false;

  @override
  void initState() {
    super.initState();
    _tagFilterState = TagFilterState();
    _infiniteScroll = InfiniteScrollState<FolderItem>(
      loader: (limit, offset) => _service.getFolderItemsPaginated(
        widget.folderId,
        limit,
        offset,
      ),
      countLoader: () => _service.getFolderItemCount(widget.folderId),
    );
    unawaited(_loadLockState());
    _metadata = _service.loadFolderMetadata(widget.folderId);
    unawaited(_infiniteScroll.loadInitial());
  }

  @override
  void dispose() {
    _tagFilterState.dispose();
    _infiniteScroll.dispose();
    super.dispose();
  }

  Future<void> _loadLockState() async {
    final isLocked = await _service.loadLockState();
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
    await _service.saveLockState(isLocked: newLockState);
  }

  Future<void> _handleEdit() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => FolderEditor(
            folderId: widget.folderId,
            hideAppBar: true,
            onClose: () => Navigator.pop(context),
          ),
        ),
      );

      // Refresh folder data after returning from editor
      if (mounted) {
        _refreshFolderData();
      }
    } catch (e, stackTrace) {
      loggerGlobal.severe(
          "FolderViewer", "Error in folder editor", e, stackTrace);
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _handleDelete(Folder folder) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      items: [
        DeletableItem(
          id: folder.id,
          title: folder.title,
          subtitle:
              folder.description.isNotEmpty ? folder.description : "Folder",
        ),
      ],
    );

    if (!confirmed || !mounted) return;

    try {
      final success = await _service.deleteFolder(folder.id);

      if (mounted) {
        if (success) {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Folder '${folder.title}' deleted"),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Failed to delete folder"),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  void _refreshFolderData() {
    _infiniteScroll.reset();
    setState(() {
      _metadata = _service.loadFolderMetadata(widget.folderId);
    });
    unawaited(_infiniteScroll.loadInitial());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<FolderResult>(
        future: _metadata,
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

          final parentItems = result.items;

          return Column(
            children: [
              _CollapsibleHeader(
                result: result,
                parentItems: parentItems,
                infiniteScroll: _infiniteScroll,
                isHeaderExpanded: _isHeaderExpanded,
                isHeaderLocked: _isHeaderLocked,
                onToggleExpanded: () => setState(
                    () => _isHeaderExpanded = !_isHeaderExpanded),
                onToggleLock: _toggleHeaderLock,
                onEdit: _handleEdit,
                onDelete: () => _handleDelete(result.data),
              ),
              Expanded(
                child: _FolderItemDisplay(
                  parentItems: parentItems,
                  infiniteScroll: _infiniteScroll,
                  tagFilterState: _tagFilterState,
                  onRefresh: _refreshFolderData,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}

class _CollapsibleHeader extends StatelessWidget {
  final FolderResult result;
  final List<FolderItem> parentItems;
  final InfiniteScrollState<FolderItem> infiniteScroll;
  final bool isHeaderExpanded;
  final bool isHeaderLocked;
  final VoidCallback onToggleExpanded;
  final VoidCallback onToggleLock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CollapsibleHeader({
    required this.result,
    required this.parentItems,
    required this.infiniteScroll,
    required this.isHeaderExpanded,
    required this.isHeaderLocked,
    required this.onToggleExpanded,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final totalItems =
          infiniteScroll.estimatedTotal + parentItems.length;

      return GestureDetector(
        onTap: isHeaderLocked ? null : onToggleExpanded,
        child: AnimatedContainer(
          duration: kDefaultAnimationDuration,
          curve: Curves.easeInOut,
          height: isHeaderExpanded ? null : 60,
          child: isHeaderExpanded
              ? FolderHeader(
                  folder: result.data,
                  tags: result.tags,
                  totalItems: totalItems,
                  onBack: () => Navigator.pop(context),
                  onHome: () => Navigator.popUntil(
                      context, (route) => route.isFirst),
                  isExpanded: isHeaderExpanded,
                  onToggle: onToggleExpanded,
                  isLocked: isHeaderLocked,
                  onToggleLock: onToggleLock,
                  onTagTap: (tagName) {
                    Navigator.pop(context);
                    final searchFilter =
                        globalSearchFilterSignal.value;
                    if (searchFilter != null) {
                      searchFilter.controller.value = "#$tagName";
                      searchFilter.controller.onSubmitted
                          ?.call("#$tagName");
                    }
                  },
                  onEdit: onEdit,
                  onDelete: onDelete,
                )
              : CollapsedHeader(
                  folder: result.data,
                  isHeaderLocked: isHeaderLocked,
                  isHeaderExpanded: isHeaderExpanded,
                  onBack: () => Navigator.pop(context),
                  onHome: () => Navigator.popUntil(
                      context, (route) => route.isFirst),
                  onToggleLock: onToggleLock,
                ),
        ),
      );
    });
  }
}

class _FolderItemDisplay extends StatelessWidget {
  final List<FolderItem> parentItems;
  final InfiniteScrollState<FolderItem> infiniteScroll;
  final TagFilterState tagFilterState;
  final VoidCallback onRefresh;

  const _FolderItemDisplay({
    required this.parentItems,
    required this.infiniteScroll,
    required this.tagFilterState,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final loadedItems = infiniteScroll.loadedItems.value;
      final allItems = [...parentItems, ...loadedItems];

      return FilterableItemDisplay(
        items: allItems,
        tagFilterState: tagFilterState,
        enableTagFiltering: true,
        displayModeContext: "folder_viewer",
        onItemTap: (item) => handleItemTap(context, item),
        onDeleteRequested: (items) => handleItemDeletion(
          context,
          items,
          onRefresh,
        ),
        onTagRequested: (items) => handleItemTagging(
          context,
          items,
          onRefresh,
        ),
        onRefreshMetadataRequested: (items) =>
            handleItemMetadataRefresh(context, items),
        onLoadMore: infiniteScroll.loadNextPage,
        isLoadingMore: infiniteScroll.isLoadingMore.value,
        hasMore: infiniteScroll.hasMore.value,
        onLoadAllRemaining: infiniteScroll.loadAll,
      );
    });
  }
}
