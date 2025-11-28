import "dart:async";
import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:database/extensions/folder/read.dart";
import "package:database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:signals/signals.dart";

import "package:chenron/features/shell/ui/widgets/rail_header.dart";
import "package:chenron/features/shell/ui/widgets/rail_quota_bar.dart";
import "package:chenron/features/shell/ui/widgets/rail_filter.dart";
import "package:chenron/features/shell/ui/widgets/folder_list.dart";
import "package:chenron/features/shell/ui/widgets/rail_bottom_section.dart";

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
    unawaited(_watchFolders());
  }

  @override
  void dispose() {
    unawaited(_foldersSubscription?.cancel());
    super.dispose();
  }

  Future<void> _watchFolders() async {
    try {
      final db = locator.get<Signal<AppDatabaseHandler>>().value;
      final appDb = db.appDatabase;

      // Watch for folder changes with items included
      _foldersSubscription = appDb
          .watchAllFolders(
        includeOptions:
            const IncludeOptions<AppDataInclude>({AppDataInclude.items}),
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
          RailHeader(
            isExtended: widget.isExtended,
            onToggleExtended: widget.onToggleExtended,
          ),
          if (widget.showQuotaBar) RailQuotaBar(isExtended: widget.isExtended),
          RailFilter(
            isExtended: widget.isExtended,
            onFilterChanged: (value) {
              setState(() {
                _filterTerm = value;
              });
            },
          ),
          Expanded(
            child: FolderList(
              isLoading: _isLoading,
              folders: _folders,
              filterTerm: _filterTerm,
              isExtended: widget.isExtended,
              selectedFolderId: widget.selectedFolderId,
              onFolderSelected: widget.onFolderSelected,
            ),
          ),
          RailBottomSection(
            showPlanInfo: widget.showPlanInfo,
            isExtended: widget.isExtended,
            onAddPressed: widget.onAddPressed,
          ),
        ],
      ),
    );
  }
}
