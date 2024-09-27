import 'package:flutter/material.dart';
import 'package:chenron/responsible_design/responsive_builder.dart';

class GridLayout<T> extends StatelessWidget {
  final List<T> items;
  final bool Function(T) isItemSelected;
  final Function(T)? onItemToggle;
  final Function(T)? onTap;
  final Widget Function(T) itemBuilder;

  const GridLayout({
    super.key,
    required this.items,
    required this.isItemSelected,
    this.onItemToggle,
    this.onTap,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, constraints) {
      int gridColumns =
          responsiveValue(context: context, xs: 2, sm: 3, md: 4, lg: 7, xl: 8);
      return GridView.count(
        crossAxisCount: gridColumns,
        childAspectRatio: 1.5,
        children: items.map((item) {
          final isSelected = isItemSelected(item);
          return Card(
            color: isSelected ? Colors.blue.withOpacity(0.1) : null,
            child: InkWell(
              onTap: () => onTap!(item),
              child: Stack(
                children: [
                  Center(child: itemBuilder(item)),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) => onItemToggle!(item),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
