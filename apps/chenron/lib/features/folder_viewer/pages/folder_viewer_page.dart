import "package:database/database.dart";
import "package:flutter/material.dart";
import "dart:async";
import "package:signals/signals_flutter.dart";
import "package:chenron/shared/constants/durations.dart";
import "package:chenron/features/folder_viewer/ui/components/folder_header.dart";
import "package:chenron/features/folder_viewer/ui/components/collapsed_header.dart";
import "package:chenron/shared/dialogs/delete_confirmation_dialog.dart";
import "package:chenron/features/folder_viewer/services/folder_viewer_service.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/features/viewer/ui/paged_viewer_display.dart";
import "package:chenron/features/folder_editor/pages/folder_editor.dart";
import "package:app_logger/app_logger.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:chenron/shared/errors/user_error_message.dart";
import "package:chenron/shared/viewer/item_handler.dart";

class FolderViewerPage extends StatefulWidget {
  final String folderId;

  /// Routes an item tap (e.g. open URL, navigate to folder, show details).
  /// When null, falls back to [openFolderItem].
  final void Function(BuildContext, FolderItem)? onItemTap;

  /// Called when a tag chip is tapped in the folder header.
  /// The caller (typically root) uses this to pop and apply a search query.
  final ValueChanged<String>? onTagSearch;
  final FolderViewerService Function()? serviceFactory;

  const FolderViewerPage({
    super.key,
    required this.folderId,
    this.onItemTap,
    this.onTagSearch,
    this.serviceFactory,
  });

  @override
  State<FolderViewerPage> createState() => _FolderViewerPageState();
}

class _FolderViewerPageState extends State<FolderViewerPage> {
  late final FolderViewerService _service;
  late Future<FolderResult> _metadata;
  late final ViewerPresenter _presenter;
  bool _isHeaderExpanded = true;
  bool _isHeaderLocked = false;

  @override
  void initState() {
    super.initState();
    _service = widget.serviceFactory?.call() ?? FolderViewerService();
    _presenter = ViewerPresenter(
      repository: _service,
      folderId: widget.folderId,
    );
    unawaited(_loadLockState());
    _metadata = _service.loadFolderMetadata(widget.folderId);
    unawaited(_presenter.init());
  }

  @override
  void dispose() {
    _presenter.dispose();
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
    setState(() {
      _metadata = _service.loadFolderMetadata(widget.folderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stream the metadata result instead of gating the whole page on
      // it — the header skeleton + item display render as soon as the
      // page mounts, then the FolderHeader content + parentItems
      // populate once the metadata Future resolves. Direct items load
      // independently through the bounded page source.
      body: FutureBuilder<FolderResult>(
        future: _metadata,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error!;
            loggerGlobal.severe("FolderViewer", "Failed to load folder", error,
                snapshot.stackTrace);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  userErrorMessage(error),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          }

          final result = snapshot.data;
          final parentItems = result?.items ?? const <FolderItem>[];

          return Column(
            children: [
              if (result == null)
                _HeaderSkeleton(
                  isHeaderLocked: _isHeaderLocked,
                  onToggleLock: _toggleHeaderLock,
                )
              else
                _CollapsibleHeader(
                  result: result,
                  parentItems: parentItems,
                  pageSource: _presenter.pageSource,
                  isHeaderExpanded: _isHeaderExpanded,
                  isHeaderLocked: _isHeaderLocked,
                  onToggleExpanded: () =>
                      setState(() => _isHeaderExpanded = !_isHeaderExpanded),
                  onToggleLock: _toggleHeaderLock,
                  onEdit: _handleEdit,
                  onDelete: () => _handleDelete(result.data),
                  onTagSearch: widget.onTagSearch,
                ),
              Expanded(
                child: PagedViewerDisplay(
                  presenter: _presenter,
                  prefixItems: parentItems,
                  displayModeContext: "folder_viewer",
                  onItemTap: (item) => handleItemTap(
                    context,
                    item,
                    widget.onItemTap ?? openFolderItem,
                  ),
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
                  onRefreshMetadataRequested: (items) =>
                      handleItemMetadataRefresh(context, items),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Stand-in for [FolderHeader] / [CollapsedHeader] while the folder
/// metadata Future is still in flight — keeps the navigation chrome
/// (back / home / lock) visible on first paint so the page doesn't
/// "blink" through a full-page loading spinner.
class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton({
    required this.isHeaderLocked,
    required this.onToggleLock,
  });

  final bool isHeaderLocked;
  final VoidCallback onToggleLock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: "Back",
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: "Home",
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 14,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(isHeaderLocked ? Icons.lock : Icons.lock_open),
              tooltip: isHeaderLocked ? "Unlock header" : "Lock header",
              onPressed: onToggleLock,
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsibleHeader extends StatelessWidget {
  final FolderResult result;
  final List<FolderItem> parentItems;
  final ViewerPageSource pageSource;
  final bool isHeaderExpanded;
  final bool isHeaderLocked;
  final VoidCallback onToggleExpanded;
  final VoidCallback onToggleLock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<String>? onTagSearch;

  const _CollapsibleHeader({
    required this.result,
    required this.parentItems,
    required this.pageSource,
    required this.isHeaderExpanded,
    required this.isHeaderLocked,
    required this.onToggleExpanded,
    required this.onToggleLock,
    required this.onEdit,
    required this.onDelete,
    this.onTagSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(builder: (context) {
      final totalItems = pageSource.totalCount.value + parentItems.length;

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
                  onHome: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  isExpanded: isHeaderExpanded,
                  onToggle: onToggleExpanded,
                  isLocked: isHeaderLocked,
                  onToggleLock: onToggleLock,
                  onTagTap: onTagSearch != null
                      ? (tagName) {
                          Navigator.pop(context);
                          onTagSearch!("#$tagName");
                        }
                      : null,
                  onEdit: onEdit,
                  onDelete: onDelete,
                )
              : CollapsedHeader(
                  folder: result.data,
                  isHeaderLocked: isHeaderLocked,
                  isHeaderExpanded: isHeaderExpanded,
                  onBack: () => Navigator.pop(context),
                  onHome: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  onToggleLock: onToggleLock,
                ),
        ),
      );
    });
  }
}
