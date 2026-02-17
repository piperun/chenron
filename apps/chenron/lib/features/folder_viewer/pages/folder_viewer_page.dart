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
            hideAppBar: false,
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
              _buildCollapsibleHeader(result, parentItems),
              _buildItemDisplay(parentItems),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCollapsibleHeader(
    FolderResult result,
    List<FolderItem> parentItems,
  ) {
    return Watch((context) {
      final totalItems =
          _infiniteScroll.estimatedTotal + parentItems.length;

      return GestureDetector(
        onTap: _isHeaderLocked
            ? null
            : () =>
                setState(() => _isHeaderExpanded = !_isHeaderExpanded),
        child: AnimatedContainer(
          duration: kDefaultAnimationDuration,
          curve: Curves.easeInOut,
          height: _isHeaderExpanded ? null : 60,
          child: _isHeaderExpanded
              ? FolderHeader(
                  folder: result.data,
                  tags: result.tags,
                  totalItems: totalItems,
                  onBack: () => Navigator.pop(context),
                  onHome: () => Navigator.popUntil(
                      context, (route) => route.isFirst),
                  isExpanded: _isHeaderExpanded,
                  onToggle: () => setState(
                      () => _isHeaderExpanded = !_isHeaderExpanded),
                  isLocked: _isHeaderLocked,
                  onToggleLock: _toggleHeaderLock,
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
                  onEdit: _handleEdit,
                  onDelete: () => _handleDelete(result.data),
                )
              : CollapsedHeader(
                  folder: result.data,
                  isHeaderLocked: _isHeaderLocked,
                  isHeaderExpanded: _isHeaderExpanded,
                  onBack: () => Navigator.pop(context),
                  onHome: () => Navigator.popUntil(
                      context, (route) => route.isFirst),
                  onToggleLock: _toggleHeaderLock,
                ),
        ),
      );
    });
  }

  Widget _buildItemDisplay(List<FolderItem> parentItems) {
    return Expanded(
      child: Watch((context) {
        final loadedItems = _infiniteScroll.loadedItems.value;
        final allItems = [...parentItems, ...loadedItems];

        return FilterableItemDisplay(
          items: allItems,
          tagFilterState: _tagFilterState,
          enableTagFiltering: true,
          displayModeContext: "folder_viewer",
          onItemTap: (item) => handleItemTap(context, item),
          onDeleteRequested: (items) => handleItemDeletion(
            context,
            items,
            _refreshFolderData,
          ),
          onTagRequested: (items) => handleItemTagging(
            context,
            items,
            _refreshFolderData,
          ),
          onRefreshMetadataRequested: (items) => handleItemMetadataRefresh(
            context,
            items,
            _refreshFolderData,
          ),
          onLoadMore: _infiniteScroll.loadNextPage,
          isLoadingMore: _infiniteScroll.isLoadingMore.value,
          hasMore: _infiniteScroll.hasMore.value,
          onLoadAllRemaining: _infiniteScroll.loadAll,
        );
      }),
    );
  }
}
