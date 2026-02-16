import "package:database/main.dart";
import "package:flutter/material.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron/shared/bottom_sheet/bottom_sheet_scaffold.dart";
import "package:chenron/shared/bottom_sheet/sheet_action_bar.dart";
import "package:chenron/shared/ui/folder_picker.dart";
import "package:chenron/utils/validation/tag_validator.dart";

class LinkEditBottomSheet extends StatefulWidget {
  final LinkEntry entry;
  final void Function(LinkEntry entry, List<Folder> folders) onSave;
  final VoidCallback onCancel;
  final List<Folder> currentFolders;

  const LinkEditBottomSheet({
    super.key,
    required this.entry,
    required this.onSave,
    required this.onCancel,
    required this.currentFolders,
  });

  @override
  State<LinkEditBottomSheet> createState() => _LinkEditBottomSheetState();
}

class _LinkEditBottomSheetState extends State<LinkEditBottomSheet> {
  late TextEditingController _urlController;
  late TextEditingController _tagsController;
  late bool _isArchived;
  late List<String> _tags;
  late List<Folder> _currentFolders;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.entry.url);
    _tags = List.from(widget.entry.tags);
    _tagsController = TextEditingController();
    _isArchived = widget.entry.isArchived;
    _currentFolders = List.from(widget.currentFolders);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addTag() {
    final parts = _tagsController.text
        .split(",")
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();

    if (parts.isEmpty) return;

    for (final tag in parts) {
      final validationError = TagValidator.validateTag(tag);
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
      if (_tags.contains(tag)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tag '$tag' already exists"),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    setState(() {
      _tags.addAll(parts);
      _tagsController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _handleSave() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("URL cannot be empty"),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final updatedEntry = widget.entry.copyWith(
      url: url,
      tags: _tags,
      isArchived: _isArchived,
      folderIds: _currentFolders.map((f) => f.id).toList(),
    );

    widget.onSave(updatedEntry, _currentFolders);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return BottomSheetScaffold(
      headerIcon: Icons.edit,
      title: "Edit Link",
      onClose: widget.onCancel,
      bodyBuilder: (scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottomPadding + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UrlField(controller: _urlController),
            const SizedBox(height: 20),
            _TagsSection(
              tags: _tags,
              controller: _tagsController,
              onAddTag: _addTag,
              onRemoveTag: _removeTag,
            ),
            const SizedBox(height: 20),
            FolderPicker(
              initialFolders: _currentFolders,
              onFoldersSelected: (folders) {
                setState(() => _currentFolders = folders);
              },
            ),
            const SizedBox(height: 20),
            _ArchiveToggle(
              value: _isArchived,
              onChanged: (value) =>
                  setState(() => _isArchived = value),
            ),
          ],
        ),
      ),
      actions: SheetActionBar(
        trailing: [
          TextButton(
            onPressed: widget.onCancel,
            child: const Text("Cancel"),
          ),
          FilledButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.save, size: 18),
            label: const Text("Update"),
          ),
        ],
      ),
    );
  }
}


class _UrlField extends StatelessWidget {
  final TextEditingController controller;

  const _UrlField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "URL",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "https://example.com",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}

class _TagsSection extends StatelessWidget {
  final List<String> tags;
  final TextEditingController controller;
  final VoidCallback onAddTag;
  final ValueChanged<String> onRemoveTag;

  const _TagsSection({
    required this.tags,
    required this.controller,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tags",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "tag1, tag2, tag3",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                onSubmitted: (_) => onAddTag(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onAddTag,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add"),
            ),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return InputChip(
                label: Text("#$tag"),
                onDeleted: () => onRemoveTag(tag),
                deleteIconColor: theme.colorScheme.error,
                backgroundColor: theme.colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        theme.colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _ArchiveToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ArchiveToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text("Archive"),
      subtitle: const Text("Archive this link when saved"),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}

