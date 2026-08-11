import "dart:async";

import "package:chenron/features/folder_viewer/ui/components/tag_filter_modal.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/state/viewer_selection_state.dart";
import "package:chenron/shared/item_display/item_grid_view.dart";
import "package:chenron/shared/item_display/item_list_view.dart";
import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:chenron/shared/item_display/item_viewport_source.dart";
import "package:chenron/shared/item_display/select_mode_action_bar.dart";
import "package:chenron/shared/item_display/view_mode_preference.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode_preference.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class PagedViewerDisplay extends StatefulWidget {
  const PagedViewerDisplay({
    super.key,
    required this.presenter,
    this.showSearch = true,
    this.displayModeContext,
    this.onItemTap,
    this.onDeleteRequested,
    this.onTagRequested,
    this.onRefreshMetadataRequested,
  });

  final ViewerPresenter presenter;
  final bool showSearch;
  final String? displayModeContext;
  final ValueChanged<FolderItem>? onItemTap;
  final ValueChanged<ViewerSelectionTarget>? onDeleteRequested;
  final ValueChanged<ViewerSelectionTarget>? onTagRequested;
  final ValueChanged<ViewerSelectionTarget>? onRefreshMetadataRequested;

  @override
  State<PagedViewerDisplay> createState() => _PagedViewerDisplayState();
}

class _PagedViewerDisplayState extends State<PagedViewerDisplay> {
  final Signal<DisplayMode> _displayMode = signal(DisplayMode.standard);
  final Signal<bool> _isSelectMode = signal(false);
  bool _disposed = false;

  ViewerPresenter get _presenter => widget.presenter;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDisplayPreferences());
  }

  Future<void> _loadDisplayPreferences() async {
    final results = await Future.wait<Object>(<Future<Object>>[
      DisplayModePreference.getDisplayMode(
        context: widget.displayModeContext,
      ),
      ViewModePreference.getViewMode(context: widget.displayModeContext),
    ]);
    if (_disposed) return;
    _displayMode.value = results[0] as DisplayMode;
    _presenter.onViewModeChanged(results[1] as ViewMode);
  }

  @override
  void dispose() {
    _disposed = true;
    _displayMode.dispose();
    _isSelectMode.dispose();
    super.dispose();
  }

  Future<void> _handleViewModeChanged(ViewMode mode) async {
    _presenter.onViewModeChanged(mode);
    await ViewModePreference.setViewMode(
      mode,
      context: widget.displayModeContext,
    );
  }

  Future<void> _handleDisplayModeChanged(DisplayMode mode) async {
    _displayMode.value = mode;
    await DisplayModePreference.setDisplayMode(
      mode,
      context: widget.displayModeContext,
    );
  }

  void _toggleSelectMode() {
    final entering = !_isSelectMode.value;
    _isSelectMode.value = entering;
    if (!entering) {
      _presenter.selectionState.clear();
    }
  }

  void _handleItemTap(FolderItem item) {
    final id = item.id;
    if (!_isSelectMode.value || id == null) {
      widget.onItemTap?.call(item);
      return;
    }
    final key = (type: item.type, id: id);
    final result = _presenter.selectionState.toggle(key);
    if (result == ViewerSelectionToggleResult.limitReached) {
      final limit = _presenter.selectionState.maxManualKeys;
      final noun = limit == 1 ? "item" : "items";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Manual selection is limited to $limit $noun. Use Select All.",
          ),
        ),
      );
    }
  }

  void _selectAllItems() {
    if (!_isSelectMode.value || !_presenter.pageSource.isCountReady) return;
    final query = _presenter.query.value;
    _presenter.selectionState.selectAllMatching(
      query,
      _presenter.pageSource.totalCount.value,
    );
  }

  ViewerSelectionTarget get _selectionTarget {
    final selection = _presenter.selectionState.value;
    final summaryGeneration = _presenter.pageSource.summaryGeneration.value;
    return ViewerSelectionTarget(
      selection: selection,
      isCurrent: () =>
          !_disposed &&
          identical(_presenter.selectionState.value, selection) &&
          _presenter.pageSource.summaryGeneration.value == summaryGeneration,
    );
  }

  bool _isItemSelected(FolderItem item) {
    return _presenter.selectionState.isSelected(_itemKey(item));
  }

  int get _selectedLinkCount {
    return switch (_presenter.selectionState.value) {
      ExplicitViewerSelection(:final keys) =>
        keys.where((key) => key.type == FolderItemType.link).length,
      AllMatchingViewerSelection(:final query, :final totalCount) =>
        totalCount > 0 && query.types.contains(FolderItemType.link) ? 1 : 0,
    };
  }

  Future<void> _openTagFilterModal() async {
    final facets = _presenter.pageSource.tagFacets.value;
    final result = await TagFilterModal.show(
      context: context,
      availableTags: facets.map((facet) => facet.tag).toList(growable: false),
      initialIncludedTags: _presenter.tagFilterState.includedTagNames,
      initialExcludedTags: _presenter.tagFilterState.excludedTagNames,
      onSearchTags: (searchText) async {
        final searched =
            await _presenter.pageSource.searchTagFacets(searchText);
        return searched.map((facet) => facet.tag).toList(growable: false);
      },
    );
    if (result == null) return;
    _presenter.tagFilterState.updateTags(
      included: result.included,
      excluded: result.excluded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(builder: (context) {
      final pageSource = _presenter.pageSource;
      pageSource.revision.value;
      final countError = pageSource.countError.value;
      final tagFacetsError = pageSource.tagFacetsError.value;
      final delegate = DelegatingItemViewportSource(
        length: () => pageSource.totalCount.value,
        itemAt: pageSource.itemAt,
        errorAt: pageSource.errorAt,
        retryAt: (index) => pageSource.retryPage(index ~/ pageSource.pageSize),
      );
      final selectionTarget = _selectionTarget;

      return Column(
        children: <Widget>[
          ItemToolbar(
            searchFilter: _presenter.searchFilter,
            selectedTypes: _presenter.selectedTypes.value,
            onFilterChanged: _presenter.onTypesChanged,
            sortMode: _presenter.sortMode.value,
            onSortChanged: _presenter.onSortChanged,
            viewMode: _presenter.viewMode.value,
            onViewModeChanged: (mode) => unawaited(
              _handleViewModeChanged(mode),
            ),
            displayMode: _displayMode.value,
            onDisplayModeChanged: (mode) => unawaited(
              _handleDisplayModeChanged(mode),
            ),
            showSearch: widget.showSearch,
            showTagFilterButton: true,
            includedTagNames: _presenter.tagFilterState.includedTagNames,
            excludedTagNames: _presenter.tagFilterState.excludedTagNames,
            onTagFilterPressed: _openTagFilterModal,
            onSearchSubmitted: _presenter.onSearchSubmitted,
            isDeleteMode: _isSelectMode.value,
            onDeleteModeToggled:
                widget.onDeleteRequested == null ? null : _toggleSelectMode,
          ),
          if (_isSelectMode.value)
            SelectModeActionBar(
              selectedCount: selectionTarget.selectedCount,
              linkCount: _selectedLinkCount,
              onSelectAll: pageSource.isCountReady ? _selectAllItems : null,
              onTag: () => widget.onTagRequested?.call(selectionTarget),
              onRefreshMetadata: () =>
                  widget.onRefreshMetadataRequested?.call(selectionTarget),
              onDelete: () => widget.onDeleteRequested?.call(selectionTarget),
              onCancel: _toggleSelectMode,
            ),
          if (countError != null || tagFacetsError != null)
            _ViewerSummaryErrorBanner(
              countFailed: countError != null,
              tagFacetsFailed: tagFacetsError != null,
              onRetry: () => unawaited(pageSource.retrySummary()),
            ),
          Expanded(
            child: _presenter.viewMode.value == ViewMode.grid
                ? ItemGridView(
                    source: delegate,
                    displayMode: _displayMode.value,
                    includedTagNames:
                        _presenter.tagFilterState.includedTagNames,
                    excludedTagNames:
                        _presenter.tagFilterState.excludedTagNames,
                    onItemTap: _handleItemTap,
                    onTagFilterTap: _presenter.tagFilterState.addIncluded,
                    aspectRatio: _displayMode.value.aspectRatio,
                    maxCrossAxisExtent: _displayMode.value.maxCrossAxisExtent,
                    isDeleteMode: _isSelectMode.value,
                    isItemSelected: _isItemSelected,
                  )
                : ItemListView(
                    source: delegate,
                    displayMode: _displayMode.value,
                    includedTagNames:
                        _presenter.tagFilterState.includedTagNames,
                    excludedTagNames:
                        _presenter.tagFilterState.excludedTagNames,
                    onItemTap: _handleItemTap,
                    isDeleteMode: _isSelectMode.value,
                    isItemSelected: _isItemSelected,
                  ),
          ),
        ],
      );
    });
  }
}

class _ViewerSummaryErrorBanner extends StatelessWidget {
  const _ViewerSummaryErrorBanner({
    required this.countFailed,
    required this.tagFacetsFailed,
    required this.onRetry,
  });

  final bool countFailed;
  final bool tagFacetsFailed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = switch ((countFailed, tagFacetsFailed)) {
      (true, true) => "Unable to load items and tag filters.",
      (true, false) => "Unable to load items.",
      (false, true) => "Unable to load tag filters.",
      (false, false) => "",
    };
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey("viewer-summary-error"),
      width: double.infinity,
      color: colors.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline, color: colors.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
          TextButton(
            key: const ValueKey("viewer-summary-retry"),
            onPressed: onRetry,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

ViewerItemKey _itemKey(FolderItem item) => (type: item.type, id: item.id!);
