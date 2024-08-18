import 'package:chenron/responsible_design/responsive_builder.dart';
import 'package:flutter/material.dart';

class FolderGrid extends StatelessWidget {
  final List<String> folders;
  final List<String> selectedFolders;
  final Function(String) onFolderToggle;

  FolderGrid({
    required this.folders,
    required this.selectedFolders,
    required this.onFolderToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, constraints) {
      int gridColumns =
          responsiveValue(context: context, xs: 2, sm: 3, md: 4, lg: 7, xl: 8);
      return GridView.count(
        crossAxisCount: gridColumns,
        childAspectRatio: 1.5,
        children: folders.map((folder) {
          final isSelected = selectedFolders.contains(folder);
          return Card(
            color: isSelected ? Colors.blue : null,
            child: InkWell(
              onTap: () => onFolderToggle(folder),
              child: Center(
                child: Text(
                  folder,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
