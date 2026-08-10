import "dart:async";

import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/ui/paged_viewer_display.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/shared/viewer/item_handler.dart";
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

  @override
  void initState() {
    super.initState();
    _presenter = widget.presenterFactory?.call() ??
        ViewerPresenter(searchFilter: widget.searchFilter);
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
        onDeleteRequested: (items) => handleItemDeletion(
          context,
          items,
          _presenter.init,
        ),
        onTagRequested: (items) => handleItemTagging(
          context,
          items,
          _presenter.init,
        ),
        onRefreshMetadataRequested: (items) =>
            handleItemMetadataRefresh(context, items),
      ),
    );
  }
}
