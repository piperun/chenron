import "package:flutter/material.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron/database/database.dart";
import "package:chenron/utils/validation/tag_validator.dart";

class LinkEditBottomSheet extends StatefulWidget {
  final LinkEntry entry;
  final ValueChanged<LinkEntry> onSave;
  final VoidCallback onCancel;
  final List<Folder>? availableFolders;

  const LinkEditBottomSheet({
    super.key,
    required this.entry,
    required this.onSave,
    required this.onCancel,
    this.availableFolders,
  });

  @override
  State<LinkEditBottomSheet> createState() => _LinkEditBottomSheetState();
}

class _LinkEditBottomSheetState extends State<LinkEditBottomSheet> {
  late TextEditingController _urlController;
  late TextEditingController _tagsController;
  late bool _isArchived;
  late List<String> _tags;
  late Set<String> _selectedFolderIds;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.entry.url);
    _tags = List.from(widget.entry.tags);
    _tagsController = TextEditingController();
    _isArchived = widget.entry.isArchived;
    _selectedFolderIds = Set.from(widget.entry.folderIds);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagsController.text.trim().toLowerCase();
    
    if (tag.isEmpty) return;
    
    // Validate using TagValidator
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
    
    // Check for duplicates
    if (_tags.contains(tag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tag '$tag' already exists"),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      _tags.add(tag);
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
        const SnackBar(content: Text("URL cannot be empty")),
      );
      return;
    }

    final updatedEntry = widget.entry.copyWith(
      url: url,
      tags: _tags,
      isArchived: _isArchived,
      folderIds: _selectedFolderIds.toList(),
    );

    widget.onSave(updatedEntry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHandle(theme),
              _buildHeader(theme),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
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
                      _buildUrlField(theme),
                      const SizedBox(height: 20),
                      _buildTagsSection(theme),
                      const SizedBox(height: 20),
                      if (widget.availableFolders != null && widget.availableFolders!.isNotEmpty) ...[
                        _buildFoldersSection(theme),
                        const SizedBox(height: 20),
                      ],
                      _buildArchiveToggle(theme),
                    ],
                  ),
                ),
              ),
              _buildActions(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.edit, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            "Edit Link",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onCancel,
            tooltip: "Close",
          ),
        ],
      ),
    );
  }

  Widget _buildUrlField(ThemeData theme) {
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
          controller: _urlController,
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

  Widget _buildTagsSection(ThemeData theme) {
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
                controller: _tagsController,
                decoration: const InputDecoration(
                  hintText: "Add tag",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _addTag,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add"),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return InputChip(
                label: Text("#$tag"),
                onDeleted: () => _removeTag(tag),
                deleteIconColor: theme.colorScheme.error,
                backgroundColor: theme.colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFoldersSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Folders",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableFolders!.map((folder) {
            final isSelected = _selectedFolderIds.contains(folder.id);
            return FilterChip(
              label: Text(folder.title),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFolderIds.add(folder.id);
                  } else {
                    _selectedFolderIds.remove(folder.id);
                  }
                });
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildArchiveToggle(ThemeData theme) {
    return SwitchListTile(
      title: const Text("Archive"),
      subtitle: const Text("Archive this link when saved"),
      value: _isArchived,
      onChanged: (value) => setState(() => _isArchived = value),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: widget.onCancel,
            child: const Text("Cancel"),
          ),
          const SizedBox(width: 12),
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
