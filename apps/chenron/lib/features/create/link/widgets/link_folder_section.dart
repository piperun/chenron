import "package:flutter/material.dart";
import "package:chenron/database/database.dart";
import "package:chenron/shared/ui/folder_picker.dart";

class LinkFolderSection extends StatelessWidget {
  final List<Folder> selectedFolders;
  final ValueChanged<List<Folder>> onFoldersChanged;

  const LinkFolderSection({
    super.key,
    required this.selectedFolders,
    required this.onFoldersChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Target Folders",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Select which folder(s) the links will be added to",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FolderPicker(
              key: const Key('link_folder_picker'),
              onFoldersSelected: onFoldersChanged,
            ),
          ],
        ),
      ),
    );
  }
}
