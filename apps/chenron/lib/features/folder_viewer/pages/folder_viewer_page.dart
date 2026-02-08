import "package:database/main.dart";
import "package:database/database.dart";
import "package:flutter/material.dart";
import "dart:async";
import "package:chenron/features/folder_viewer/ui/components/folder_header.dart";
import "package:chenron/shared/item_display/filterable_item_display.dart";
import "package:chenron/shared/dialogs/delete_confirmation_dialog.dart";
import "package:chenron/features/folder_viewer/services/folder_viewer_service.dart";

import "package:chenron/shared/tag_filter/tag_filter_state.dart";
import "package:chenron/features/folder_editor/pages/folder_editor.dart";
import "package:logger/logger.dart";
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
  late Future<FolderResult> _folderData;
  late final TagFilterState _tagFilterState;
  bool _isHeaderExpanded = true;
  bool _isHeaderLocked = false;

  @override
  void initState() {
    super.initState();
    _tagFilterState = TagFilterState();
    unawaited(_loadLockState());
    _folderData = _service.loadFolderWithParents(widget.folderId);
  }

  @override
  void dispose() {
    _tagFilterState.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error opening editor: $e"),
            backgroundColor: Colors.red,
          ),
        );
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
            content: Text("Error deleting folder: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _refreshFolderData() {
    setState(() {
      _folderData = _service.loadFolderWithParents(widget.folderId);
    });
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

          return Column(
            children: [
              // Collapsible header
              GestureDetector(
                onTap: _isHeaderLocked
                    ? null
                    : () =>
                        setState(() => _isHeaderExpanded = !_isHeaderExpanded),
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
                          onHome: () =>
                              Navigator.popUntil(context, (route) => route.isFirst),
                          isExpanded: _isHeaderExpanded,
                          onToggle: () => setState(
                              () => _isHeaderExpanded = !_isHeaderExpanded),
                          isLocked: _isHeaderLocked,
                          onToggleLock: _toggleHeaderLock,
                          onTagTap: (tagName) {
                            Navigator.pop(context);
                            final searchFilter = globalSearchFilterSignal.value;
                            if (searchFilter != null) {
                              searchFilter.controller.value = "#$tagName";
                              searchFilter.controller.onSubmitted
                                  ?.call("#$tagName");
                            }
                          },
                          onEdit: _handleEdit,
                          onDelete: () => _handleDelete(result.data),
                        )
                      : _CollapsedHeader(
                          folder: result.data,
                          isHeaderLocked: _isHeaderLocked,
                          isHeaderExpanded: _isHeaderExpanded,
                          onBack: () => Navigator.pop(context),
                          onHome: () =>
                              Navigator.popUntil(context, (route) => route.isFirst),
                          onToggleLock: _toggleHeaderLock,
                        ),
                ),
              ),
              Expanded(
                child: FilterableItemDisplay(
                  items: result.items,
                  tagFilterState: _tagFilterState,
                  enableTagFiltering: true,
                  displayModeContext: "folder_viewer",
                  onItemTap: (item) => handleItemTap(context, item),
                  onDeleteRequested: (items) => handleItemDeletion(
                    context,
                    items,
                    _refreshFolderData,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CollapsedHeader extends StatelessWidget {
  final Folder folder;
  final bool isHeaderLocked;
  final bool isHeaderExpanded;
  final VoidCallback onBack;
  final VoidCallback onHome;
  final VoidCallback onToggleLock;

  const _CollapsedHeader({
    required this.folder,
    required this.isHeaderLocked,
    required this.isHeaderExpanded,
    required this.onBack,
    required this.onHome,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.home, color: foreground),
            onPressed: onHome,
          ),
          IconButton(
            icon: Icon(Icons.arrow_back, color: foreground),
            onPressed: onBack,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              folder.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: foreground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
                isHeaderLocked ? Icons.lock : Icons.lock_open,
                key: ValueKey<bool>(isHeaderLocked),
                color: foreground,
              ),
            ),
            onPressed: onToggleLock,
          ),
          Icon(
            isHeaderExpanded ? Icons.expand_less : Icons.expand_more,
            color: foreground.withValues(alpha: isHeaderLocked ? 0.4 : 1.0),
          ),
        ],
      ),
    );
  }
}
