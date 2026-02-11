import "package:database/main.dart";
import "package:flutter/material.dart";
import "package:chenron/shared/section_card/section_card.dart";
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

    return CardSection(
      sectionIcon: const Icon(Icons.folder),
      title: Text(
        "Target Folders",
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      description: Text(
        "Select which folder(s) the links will be added to",
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      children: [
        FolderPicker(
          key: const Key("link_folder_picker"),
          initialFolders: selectedFolders,
          onFoldersSelected: onFoldersChanged,
        ),
      ],
    );
  }
}
