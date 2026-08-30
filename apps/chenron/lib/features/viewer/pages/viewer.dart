import "dart:async";

import "package:catalog/catalog.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/services/viewer_bulk_service.dart";
import "package:chenron/features/viewer/ui/paged_viewer_display.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/shared/viewer/item_handler.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter/material.dart";

class Viewer extends StatefulWidget {
  const Viewer({
    super.key,
    this.searchFilter,
    this.presenterFactory,
  });

  final SearchFilter? searchFilter;
  final ViewerPresenter Function()? presenterFactory;

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  late final ViewerPresenter _presenter;
  late final ViewerBulkService _bulkService;

  @override
  void initState() {
    super.initState();
    _presenter = widget.presenterFactory?.call() ??
        ViewerPresenter(searchFilter: widget.searchFilter);
    _bulkService = ViewerBulkService(
      // `CatalogSelectionLeases` is an optional capability the pager does not
      // carry, so the source has to be asked for it. Every source this page is
      // ever given holds leases: the presenter builds a `ViewerModel` when it
      // is given none, and a test that injects a presenter injects a source
      // with them.
      repository: _presenter.pageSource.source
          as CatalogSelectionLeases<FolderItem, ViewerQuery>,
      bulkUpdateBoundary: _presenter.pageSource,
    );
    if (widget.searchFilter != null) {
      widget.searchFilter!.controller.onSubmitted =
          _presenter.onSearchSubmitted;
    }
    unawaited(_presenter.init());
  }

  @override
  void dispose() {
    if (widget.searchFilter != null) {
      widget.searchFilter!.controller.onSubmitted = null;
    }
    _presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PagedViewerDisplay(
        presenter: _presenter,
        showSearch: false,
        displayModeContext: "viewer",
        onItemTap: (item) => handleItemTap(context, item, openFolderItem),
        onDeleteRequested: (selection) => handleViewerSelectionDeletion(
          context,
          selection,
          _bulkService,
          _presenter.init,
        ),
        onTagRequested: (selection) => handleViewerSelectionTagging(
          context,
          selection,
          _bulkService,
          _presenter.init,
        ),
        onRefreshMetadataRequested: (selection) =>
            handleViewerSelectionMetadataRefresh(
          context,
          selection,
          _bulkService,
        ),
      ),
    );
  }
}
