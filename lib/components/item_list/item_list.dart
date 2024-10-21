import "package:flutter/material.dart";
import "package:chenron/components/item_list/layout/list.dart";
import "package:chenron/components/item_list/layout/grid.dart";

enum ViewMode {
  list,
  grid,
}

class ItemList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) listItemBuilder;
  final Widget Function(BuildContext, T) gridItemBuilder;
  final bool Function(T) isItemSelected;
  final Function(T)? onItemToggle;
  final Function(T)? onTap;

  const ItemList({
    super.key,
    required this.items,
    required this.listItemBuilder,
    required this.gridItemBuilder,
    required this.isItemSelected,
    this.onItemToggle,
    this.onTap,
  });

  @override
  State<ItemList<T>> createState() => _ItemListState<T>();
}

class _ItemListState<T> extends State<ItemList<T>> {
  ViewMode viewMode = ViewMode.list;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Column(
        children: [
          TableToolBar(
            viewMode: viewMode,
            onViewModeChanged: (newMode) {
              setState(() {
                viewMode = newMode;
              });
            },
          ),
          Tabular<T>(
            viewMode: viewMode,
            items: widget.items,
            listItemBuilder: widget.listItemBuilder,
            gridItemBuilder: widget.gridItemBuilder,
            isItemSelected: widget.isItemSelected,
            onItemToggle: widget.onItemToggle,
            onTap: widget.onTap,
          ),
        ],
      ),
    );
  }
}

class Tabular<T> extends StatelessWidget {
  final ViewMode viewMode;
  final List<T> items;
  final Widget Function(BuildContext, T) listItemBuilder;
  final Widget Function(BuildContext, T) gridItemBuilder;
  final bool Function(T) isItemSelected;
  final Function(T)? onItemToggle;
  final Function(T)? onTap;

  const Tabular({
    super.key,
    required this.viewMode,
    required this.items,
    required this.listItemBuilder,
    required this.gridItemBuilder,
    required this.isItemSelected,
    this.onItemToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (viewMode) {
      case ViewMode.list:
        return ListLayout<T>(
          items: items,
          itemWidgetBuilder: (context, item) => listItemBuilder(context, item),
          isItemSelected: isItemSelected,
          onItemToggle: onItemToggle,
          onTap: onTap,
        );
      case ViewMode.grid:
        return GridLayout<T>(
          items: items,
          itemWidgetBuilder: (context, item) => gridItemBuilder(context, item),
        );
    }
  }
}

class TableToolBar extends StatelessWidget {
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;

  const TableToolBar({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            // Toggle the view mode
            final newMode =
                viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
            // Notify the parent about the change
            onViewModeChanged(newMode);
          },
          icon: viewMode == ViewMode.list
              ? const Icon(Icons.grid_view)
              : const Icon(Icons.view_list),
        ),
      ],
    );
  }
}
