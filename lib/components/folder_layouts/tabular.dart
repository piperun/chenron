import 'package:flutter/material.dart';
import 'list.dart';
import 'grid.dart';

enum LayoutType { list, grid }

class Tabular<T> extends StatefulWidget {
  final List<T> items;
  final bool Function(T) isItemSelected;
  final Function(T)? onItemToggle;
  final Function(T)? onTap;
  final Widget Function(T) listItemBuilder;
  final Widget Function(T) gridItemBuilder;

  const Tabular({
    super.key,
    required this.items,
    required this.isItemSelected,
    this.onItemToggle,
    this.onTap,
    required this.listItemBuilder,
    required this.gridItemBuilder,
  });

  @override
  _TabularState<T> createState() => _TabularState<T>();
}

class _TabularState<T> extends State<Tabular<T>> {
  LayoutType _currentLayout = LayoutType.grid;

  void _toggleLayout() {
    setState(() {
      _currentLayout =
          _currentLayout == LayoutType.grid ? LayoutType.list : LayoutType.grid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _toggleLayout,
          child: Text(_currentLayout == LayoutType.grid
              ? 'Switch to List View'
              : 'Switch to Grid View'),
        ),
        Expanded(
          child: _currentLayout == LayoutType.grid
              ? GridLayout<T>(
                  items: widget.items,
                  isItemSelected: widget.isItemSelected,
                  onItemToggle: widget.onItemToggle,
                  onTap: widget.onTap,
                  itemBuilder: widget.gridItemBuilder,
                )
              : ListLayout<T>(
                  items: widget.items,
                  isItemSelected: widget.isItemSelected,
                  onItemToggle: widget.onItemToggle!,
                  onTap: widget.onTap!,
                  itemBuilder: widget.listItemBuilder,
                ),
        ),
      ],
    );
  }
}
