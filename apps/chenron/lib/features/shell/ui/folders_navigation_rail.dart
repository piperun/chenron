import "dart:async";
import "package:flutter/material.dart";
import "package:chenron/database/database.dart" show AppDataInclude;
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/db_result.dart";
import "package:chenron/shared/patterns/include_options.dart";
import "package:signals/signals.dart";

/// A navigation rail that displays folders with filtering, quota management,
/// and plan information.
///
/// Supports both extended (280px) and collapsed (72px) states.
/// Feature flags control visibility of sync-related and premium features.
class FoldersNavigationRail extends StatefulWidget {
  final String? selectedFolderId;
  final Function(String folderId) onFolderSelected;
  final bool isExtended;
  final VoidCallback onToggleExtended;
  final VoidCallback onAddPressed;

  // Feature flags for premium/sync features
  final bool showSyncFeatures;
  final bool showPlanInfo;
  final bool showQuotaBar;

  const FoldersNavigationRail({
    super.key,
    required this.selectedFolderId,
    required this.onFolderSelected,
    required this.isExtended,
    required this.onToggleExtended,
    required this.onAddPressed,
    this.showSyncFeatures = false,
    this.showPlanInfo = false,
    this.showQuotaBar = false,
  });

  @override
  State<FoldersNavigationRail> createState() => _FoldersNavigationRailState();
}

class _FoldersNavigationRailState extends State<FoldersNavigationRail> {
  String _filterTerm = "";
  List<FolderResult> _folders = [];
  bool _isLoading = true;
  StreamSubscription<List<FolderResult>>? _foldersSubscription;

  @override
  void initState() {
    super.initState();
    _watchFolders();
  }

  @override
  void dispose() {
    _foldersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _watchFolders() async {
    try {
      final db = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
      final appDb = db.appDatabase;
      
      // Watch for folder changes with items included
      _foldersSubscription = appDb
          .watchAllFolders(
            includeOptions: const IncludeOptions<AppDataInclude>({AppDataInclude.items}),
          )
          .listen((folders) {
        if (mounted) {
          setState(() {
            _folders = folders;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.isExtended ? 280 : 72,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeaderSection(),
          if (widget.showQuotaBar) _buildQuotaBar(),
          _buildFilterSection(),
          Expanded(
            child: _buildFolderList(),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.isExtended)
            const Text(
              "FOLDERS",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          IconButton(
            icon: Icon(widget.isExtended ? Icons.menu_open : Icons.menu),
            onPressed: widget.onToggleExtended,
            tooltip: widget.isExtended ? "Collapse" : "Expand",
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaBar() {
    // Placeholder for quota bar - will be fully implemented later
    return Visibility(
      visible: widget.showQuotaBar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isExtended)
              const Text(
                "0 / 20",
                style: TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: 0.0,
              backgroundColor: Colors.grey.shade800,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    if (!widget.isExtended) {
      return IconButton(
        icon: const Icon(Icons.filter_list, size: 20),
        onPressed: () {},
        tooltip: "Filter folders",
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Filter folders...",
          prefixIcon: const Icon(Icons.filter_list, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          isDense: true,
        ),
        onChanged: (value) {
          setState(() {
            _filterTerm = value;
          });
        },
      ),
    );
  }

  Widget _buildFolderList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Filter folders based on search term
    final filteredFolders = _filterTerm.isEmpty
        ? _folders
        : _folders
            .where((folder) =>
                folder.data.title
                    .toLowerCase()
                    .contains(_filterTerm.toLowerCase()))
            .toList();

    if (filteredFolders.isEmpty) {
      return Center(
        child: widget.isExtended
            ? Text(
                _filterTerm.isEmpty
                    ? "No folders yet.\nCreate one to get started."
                    : "No folders match '$_filterTerm'",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              )
            : const Icon(Icons.folder_outlined, color: Colors.grey),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      itemCount: filteredFolders.length,
      itemBuilder: (context, index) {
        final folder = filteredFolders[index];
        return _buildFolderRow(folder);
      },
    );
  }

  Widget _buildFolderRow(FolderResult folder) {
    final isSelected = folder.data.id == widget.selectedFolderId;
    final isSynced = true; // TODO: Add synced field to Folder model

    return InkWell(
      onTap: () => widget.onFolderSelected(folder.data.id),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Folder indicator dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (widget.isExtended) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  folder.data.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              // Item count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${folder.items.length}",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              // Not synced badge (only if sync features enabled)
              if (!isSynced && widget.showSyncFeatures) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    border: Border.all(color: Colors.red.shade700),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Not synced",
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Plan info section (hidden by default)
          if (widget.showPlanInfo)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.isExtended) const Text("Free", style: TextStyle(fontSize: 12)),
                  TextButton(
                    onPressed: _showUpgradeDialog,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: Colors.blue.shade700,
                        style: BorderStyle.solid,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      widget.isExtended ? "Upgrade" : "↑",
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          // Add New button (always shown)
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    if (widget.isExtended) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: widget.onAddPressed,
          icon: const Icon(Icons.add),
          label: const Text("Add New"),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: widget.onAddPressed,
      tooltip: "Add New",
      mini: true,
      child: const Icon(Icons.add),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Upgrade Plan"),
        content: const Text(
          "Premium features coming soon!\n\nChoose from Free, Premium 1, Premium 2, or Pay-as-you-go plans.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
