import "package:flutter/material.dart";
import "package:chenron/features/folder_viewer/ui/components/folder_header.dart";
import "package:chenron/shared/item_display/filterable_item_display.dart";
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
              includeOptions:
                  const IncludeOptions({AppDataInclude.items, AppDataInclude.tags}),
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

          // Debug: print item tags
          print('FOLDER VIEWER DEBUG: ${result.items.length} items, ${result.tags.length} folder tags');
          for (final item in result.items.take(3)) {
            print('  Item ${item.id}: ${item.tags.length} tags - ${item.tags.map((t) => t.name).join(", ")}');
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
                            viewerViewModelSignal
                                .value.searchController.text = tagName;
                          },
                        )
                      : _buildCollapsedHeader(result.data),
                ),
              ),
              Expanded(
                child: FilterableItemDisplay(
                  items: result.items,
                  enableTagFiltering: true,
                  displayModeContext: 'folder_viewer',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
