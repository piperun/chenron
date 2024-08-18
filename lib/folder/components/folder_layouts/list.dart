import 'package:flutter/material.dart';

class FolderList extends StatelessWidget {
  final List<String> folders;
  final List<String> selectedFolders;
  final Function(String) onFolderToggle;

  const FolderList({
    super.key,
    required this.folders,
    required this.selectedFolders,
    required this.onFolderToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        final isSelected = selectedFolders.contains(folder);
        return ListTile(
          title: Text(folder),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              onFolderToggle(folder);
            },
          ),
          onTap: () => onFolderToggle(folder),
        );
      },
    );
  }
}
