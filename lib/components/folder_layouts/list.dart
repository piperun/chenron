import 'package:flutter/material.dart';

class ListLayout<T> extends StatelessWidget {
  final List<T> items;
  final bool Function(T) isItemSelected;
  final Function(T)? onItemToggle;
  final Function(T)? onTap;
  final Widget Function(T) itemBuilder;

  const ListLayout({
    Key? key,
    required this.items,
    required this.isItemSelected,
    required this.onItemToggle,
    required this.onTap,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = isItemSelected(item);
        return ListTile(
          title: itemBuilder(item),
          titleAlignment: ListTileTitleAlignment.center,
          trailing: Checkbox(
            value: isSelected,
            onChanged: (bool? value) => onItemToggle!(item),
          ),
          onTap: () => onTap!(item),
        );
      },
    );
  }
}
