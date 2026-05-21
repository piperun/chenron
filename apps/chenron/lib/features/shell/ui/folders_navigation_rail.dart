import "dart:async";
import "package:app_logger/app_logger.dart";
import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:chenron/locator.dart";
import "package:chenron/utils/safe_async.dart";
import "package:signals/signals.dart";

import "package:chenron/features/shell/ui/sections/navigation_section.dart";
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
  final void Function(String folderId) onFolderSelected;
  final bool isExtended;
  final VoidCallback onToggleExtended;
  final VoidCallback onAddPressed;
  final NavigationSection currentSection;
  final void Function(NavigationSection) onSectionSelected;

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
    required this.currentSection,
    required this.onSectionSelected,
    this.showSyncFeatures = false,
    this.showPlanInfo = false,
    this.showQuotaBar = false,
  });

  @override
  State<FoldersNavigationRail> createState() => _FoldersNavigationRailState();
}

class _FoldersNavigationRailState extends State<FoldersNavigationRail> {
  String _filterTerm = "";
  // Fast path — folder rows without counts. Populated by the first
  // `select(folders).watch()` emission, which is cheap because it
  // skips the count aggregation join.
  List<Folder> _folderRows = const <Folder>[];
  // Slow path — per-folder counts, populated when the
  // `watchFoldersWithItemCounts` stream catches up. Indexed by folder
  // ID; absent ids render with no badges (the FolderList row already
  // hides badges when the count is 0).
  Map<String, Map<FolderItemType, int>> _countsById =
      const <String, Map<FolderItemType, int>>{};
  bool _isLoading = true;
  StreamSubscription<List<Folder>>? _foldersSubscription;
  StreamSubscription<List<FolderItemCounts>>? _countsSubscription;

  @override
  void initState() {
    super.initState();
    _watchFolders();
  }

  @override
  void dispose() {
    unawaited(_foldersSubscription?.cancel());
    unawaited(_countsSubscription?.cancel());
    super.dispose();
  }

  void _watchFolders() {
    final AppDatabase appDb;
    try {
      appDb = locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;
    } catch (e, s) {
      loggerGlobal.severe(
          "FoldersNavigationRail", "Locator missing AppDatabaseLifecycle", e, s);
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Fast path: bare folder rows. This stream's first emission is
    // a `SELECT * FROM folders` with no joins — fast even on cold
    // SQLite + drift statement caches, so the rail paints folder
    // titles on first frame.
    _foldersSubscription = safeWatch<List<Folder>>(
      appDb.select(appDb.folders).watch(),
      tag: "FoldersNavigationRail.folders",
      onData: (rows) {
        if (mounted) {
          setState(() {
            _folderRows = rows;
            _isLoading = false;
          });
        }
      },
      onUiError: (_) {
        if (mounted) setState(() => _isLoading = false);
      },
    );

    // Slow path: per-type counts. Joins folders × items with a
    // GROUP BY aggregate — heavier, but its result is only used to
    // populate the badges. Coming in after the titles already
    // rendered, so the latency isn't on the critical first-paint
    // path.
    _countsSubscription = safeWatch<List<FolderItemCounts>>(
      appDb.watchFoldersWithItemCounts(),
      tag: "FoldersNavigationRail.counts",
      onData: (counts) {
        if (mounted) {
          setState(() {
            _countsById = <String, Map<FolderItemType, int>>{
              for (final c in counts) c.id: c.counts,
            };
          });
        }
      },
    );
  }

  /// Project the current `_folderRows` + `_countsById` snapshot into
  /// the `List<FolderItemCounts>` shape `FolderList` consumes. Folders
  /// whose counts haven't arrived yet get an empty `counts` map; the
  /// row builder already hides badges for zero counts, so the visual
  /// is "titles only" → "titles + badges" as the count stream catches
  /// up.
  List<FolderItemCounts> _displayFolders() {
    return <FolderItemCounts>[
      for (final folder in _folderRows)
        FolderItemCounts(
          id: folder.id,
          title: folder.title,
          description: folder.description,
          color: folder.color,
          createdAt: folder.createdAt,
          updatedAt: folder.updatedAt,
          counts: _countsById[folder.id] ?? const <FolderItemType, int>{},
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.isExtended ? 280 : 72,
      child: DecoratedBox(
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
            currentSection: widget.currentSection,
            onSectionSelected: widget.onSectionSelected,
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
              folders: _displayFolders(),
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
      ),
    );
  }
}
