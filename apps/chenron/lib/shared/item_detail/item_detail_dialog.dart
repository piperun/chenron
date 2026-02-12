import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:database/database.dart";
import "package:database/main.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/locator.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/shared/item_detail/item_detail_data.dart";
import "package:chenron/shared/item_detail/item_detail_service.dart";
import "package:chenron/shared/utils/time_formatter.dart";
import "package:chenron/utils/validation/tag_validator.dart";

/// Shows the item detail dialog for any item type.
void showItemDetailDialog(
  BuildContext context, {
  required String itemId,
  required FolderItemType itemType,
}) {
  unawaited(showDialog(
    context: context,
    builder: (context) => ItemDetailDialog(
      itemId: itemId,
      itemType: itemType,
    ),
  ));
}

class ItemDetailDialog extends StatefulWidget {
  final String itemId;
  final FolderItemType itemType;

  const ItemDetailDialog({
    super.key,
    required this.itemId,
    required this.itemType,
  });

  @override
  State<ItemDetailDialog> createState() => _ItemDetailDialogState();
}

class _ItemDetailDialogState extends State<ItemDetailDialog> {
  late final ItemDetailService _service;
  ItemDetailData? _data;
  bool _isLoading = true;
  bool _isEditing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final db =
        locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;
    _service = ItemDetailService(db);
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    try {
      final data =
          await _service.fetchItem(widget.itemId, widget.itemType);
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
          _error = data == null ? "Item not found" : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Failed to load: $e";
        });
      }
    }
  }

  Future<void> _handleAddTag(String tagName) async {
    await _service.addTag(widget.itemId, widget.itemType, tagName);
    await _loadData();
  }

  Future<void> _handleRemoveTag(String tagId) async {
    await _service.removeTag(widget.itemId, widget.itemType, tagId);
    await _loadData();
  }

  Future<void> _handleAddToFolder(String folderId) async {
    await _service.addToFolder(
        widget.itemId, widget.itemType, folderId);
    await _loadData();
  }

  Future<void> _handleRemoveFromFolder(String folderId) async {
    await _service.removeFromFolder(widget.itemId, folderId);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: screenSize.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailHeader(
              itemType: widget.itemType,
              title: _data?.title,
              isEditing: _isEditing,
              onToggleEdit: () => setState(() => _isEditing = !_isEditing),
              onClose: () => Navigator.of(context).pop(),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(_error!, style: theme.textTheme.bodyLarge),
                  ],
                ),
              )
            else if (_data != null)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TypeBadge(type: _data!.itemType),
                      const SizedBox(height: 16),
                      _ContentSection(data: _data!),
                      _DatesSection(
                        createdAt: _data!.createdAt,
                        updatedAt: _data!.updatedAt,
                      ),
                      const SizedBox(height: 16),
                      _TagsSection(
                        tags: _data!.tags,
                        isEditing: _isEditing,
                        onTagAdded: _handleAddTag,
                        onTagRemoved: _handleRemoveTag,
                      ),
                      const SizedBox(height: 16),
                      _FoldersSection(
                        parentFolders: _data!.parentFolders,
                        isEditing: _isEditing,
                        itemType: widget.itemType,
                        itemId: widget.itemId,
                        onAddToFolder: _handleAddToFolder,
                        onRemoveFromFolder: _handleRemoveFromFolder,
                        fetchAllFolders: _service.fetchAllFolders,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _DetailHeader extends StatelessWidget {
  final FolderItemType itemType;
  final String? title;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final VoidCallback onClose;

  const _DetailHeader({
    required this.itemType,
    required this.title,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _iconForType(itemType),
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title ?? "Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit_outlined),
            onPressed: onToggleEdit,
            tooltip: isEditing ? "Done editing" : "Edit",
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: "Close",
          ),
        ],
      ),
    );
  }

  static IconData _iconForType(FolderItemType type) {
    return switch (type) {
      FolderItemType.link => Icons.link,
      FolderItemType.document => Icons.description,
      FolderItemType.folder => Icons.folder,
    };
  }
}

// ---------------------------------------------------------------------------
// Type badge
// ---------------------------------------------------------------------------

class _TypeBadge extends StatelessWidget {
  final FolderItemType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _InfoSection(
      title: "Type",
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          type.name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content section (type-specific)
// ---------------------------------------------------------------------------

class _ContentSection extends StatelessWidget {
  final ItemDetailData data;

  const _ContentSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return switch (data.itemType) {
      FolderItemType.link => _LinkContent(data: data),
      FolderItemType.document => _DocumentContent(data: data),
      FolderItemType.folder => _FolderContent(data: data),
    };
  }
}

class _LinkContent extends StatelessWidget {
  final ItemDetailData data;

  const _LinkContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.url != null) ...[
          _LinkMetadataSection(url: data.url!),
          _InfoSection(
            title: "URL",
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    data.url!,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: "monospace",
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () => unawaited(
                      Clipboard.setData(ClipboardData(text: data.url!))),
                  tooltip: "Copy URL",
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (data.domain != null) ...[
            _InfoSection(
              title: "Domain",
              child: Text(
                data.domain!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
        if (data.archiveOrgUrl != null ||
            data.archiveIsUrl != null ||
            data.localArchivePath != null) ...[
          _InfoSection(
            title: "Archives",
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (data.archiveOrgUrl != null)
                  const _ArchiveBadge(label: "archive.org"),
                if (data.archiveIsUrl != null)
                  const _ArchiveBadge(label: "archive.is"),
                if (data.localArchivePath != null)
                  const _ArchiveBadge(label: "Local backup"),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _ArchiveBadge extends StatelessWidget {
  final String label;

  const _ArchiveBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class _LinkMetadataSection extends StatefulWidget {
  final String url;

  const _LinkMetadataSection({required this.url});

  @override
  State<_LinkMetadataSection> createState() => _LinkMetadataSectionState();
}

class _LinkMetadataSectionState extends State<_LinkMetadataSection> {
  late final Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _future = MetadataFactory.getOrFetch(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<Map<String, dynamic>?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final title = snapshot.data?["title"] as String?;
        final description = snapshot.data?["description"] as String?;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title.isNotEmpty) ...[
              _InfoSection(
                title: "Title",
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (description != null && description.isNotEmpty) ...[
              _InfoSection(
                title: "Description",
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}

class _DocumentContent extends StatelessWidget {
  final ItemDetailData data;

  const _DocumentContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.fileType != null) ...[
          _InfoSection(
            title: "File Type",
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                data.fileType!.displayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (data.fileSize != null) ...[
          _InfoSection(
            title: "File Size",
            child: Text(
              _formatFileSize(data.fileSize!),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (data.filePath != null) ...[
          _InfoSection(
            title: "File Path",
            child: SelectableText(
              data.filePath!,
              style: TextStyle(
                fontSize: 13,
                fontFamily: "monospace",
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    }
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  }
}

class _FolderContent extends StatelessWidget {
  final ItemDetailData data;

  const _FolderContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.description != null && data.description!.isNotEmpty) ...[
          _InfoSection(
            title: "Description",
            child: Text(
              data.description!,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (data.color != null) ...[
          _InfoSection(
            title: "Color",
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color(data.color!),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _InfoSection(
          title: "Contents",
          child: Text(
            _formatContents(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatContents() {
    final parts = <String>[];
    if (data.linkCount > 0) {
      parts.add("${data.linkCount} ${data.linkCount == 1 ? 'link' : 'links'}");
    }
    if (data.documentCount > 0) {
      parts.add(
          "${data.documentCount} ${data.documentCount == 1 ? 'document' : 'documents'}");
    }
    if (data.folderCount > 0) {
      parts.add(
          "${data.folderCount} ${data.folderCount == 1 ? 'folder' : 'folders'}");
    }
    return parts.isEmpty ? "Empty" : parts.join(", ");
  }
}

// ---------------------------------------------------------------------------
// Dates section
// ---------------------------------------------------------------------------

class _DatesSection extends StatelessWidget {
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const _DatesSection({this.createdAt, this.updatedAt});

  @override
  Widget build(BuildContext context) {
    if (createdAt == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final showUpdated =
        updatedAt != null && updatedAt != createdAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoSection(
          title: "Created",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TimeFormatter.formatFull(createdAt),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "(${TimeFormatter.formatRelative(createdAt)})",
                style: TextStyle(
                  fontSize: 13,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        if (showUpdated) ...[
          const SizedBox(height: 16),
          _InfoSection(
            title: "Updated",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TimeFormatter.formatFull(updatedAt),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "(${TimeFormatter.formatRelative(updatedAt)})",
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tags section
// ---------------------------------------------------------------------------

class _TagsSection extends StatefulWidget {
  final List<Tag> tags;
  final bool isEditing;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;

  const _TagsSection({
    required this.tags,
    required this.isEditing,
    required this.onTagAdded,
    required this.onTagRemoved,
  });

  @override
  State<_TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<_TagsSection> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleAddTag() {
    final tag = _controller.text.trim().toLowerCase();
    if (tag.isEmpty) return;

    final validationError = TagValidator.validateTag(tag);
    if (validationError != null) {
      setState(() => _errorText = validationError);
      return;
    }

    if (widget.tags.any((t) => t.name == tag)) {
      setState(() => _errorText = "Tag '$tag' already exists");
      return;
    }

    widget.onTagAdded(tag);
    _controller.clear();
    setState(() => _errorText = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _InfoSection(
      title: "Tags",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isEditing) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Add tag",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.tag),
                      errorText: _errorText,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _handleAddTag(),
                    onChanged: (_) {
                      if (_errorText != null) {
                        setState(() => _errorText = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _handleAddTag,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (widget.tags.isEmpty)
            Text(
              "No tags",
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.tags.map((tag) {
                if (widget.isEditing) {
                  return InputChip(
                    label: Text("#${tag.name}"),
                    onDeleted: () => widget.onTagRemoved(tag.id),
                    deleteIconColor: theme.colorScheme.error,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: theme.colorScheme.secondary
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return _ReadOnlyTagChip(tag: tag);
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _ReadOnlyTagChip extends StatelessWidget {
  final Tag tag;

  const _ReadOnlyTagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color baseColor = colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: baseColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tag, size: 12, color: baseColor),
          const SizedBox(width: 4),
          Text(
            tag.name,
            style: TextStyle(
              fontSize: 11,
              color: baseColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Folders section
// ---------------------------------------------------------------------------

class _FoldersSection extends StatelessWidget {
  final List<Folder> parentFolders;
  final bool isEditing;
  final FolderItemType itemType;
  final String itemId;
  final ValueChanged<String> onAddToFolder;
  final ValueChanged<String> onRemoveFromFolder;
  final Future<List<Folder>> Function() fetchAllFolders;

  const _FoldersSection({
    required this.parentFolders,
    required this.isEditing,
    required this.itemType,
    required this.itemId,
    required this.onAddToFolder,
    required this.onRemoveFromFolder,
    required this.fetchAllFolders,
  });

  Future<void> _handleSelectFolders(BuildContext context) async {
    final allFolders = await fetchAllFolders();

    // Exclude self for folders to prevent circular reference
    final available = itemType == FolderItemType.folder
        ? allFolders.where((f) => f.id != itemId).toList()
        : allFolders;

    if (!context.mounted) return;

    unawaited(showDialog(
      context: context,
      builder: (context) => _FolderMembershipDialog(
        availableFolders: available,
        currentFolders: parentFolders,
        onConfirm: (selected) {
          final currentIds = parentFolders.map((f) => f.id).toSet();
          final selectedIds = selected.map((f) => f.id).toSet();

          // Add new
          for (final id in selectedIds.difference(currentIds)) {
            onAddToFolder(id);
          }
          // Remove old
          for (final id in currentIds.difference(selectedIds)) {
            onRemoveFromFolder(id);
          }
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _InfoSection(
      title: "In Folders",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (parentFolders.isEmpty)
            Text(
              "Not in any folder",
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...parentFolders.map((folder) {
                  if (isEditing) {
                    return InputChip(
                      avatar: const Icon(Icons.folder, size: 16),
                      label: Text(folder.title),
                      onDeleted: () => onRemoveFromFolder(folder.id),
                      deleteIconColor: theme.colorScheme.error,
                    );
                  }
                  return Chip(
                    avatar: const Icon(Icons.folder, size: 16),
                    label: Text(folder.title),
                  );
                }),
              ],
            ),
          if (isEditing) ...[
            const SizedBox(height: 8),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text("Add to folder"),
              onPressed: () => _handleSelectFolders(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _FolderMembershipDialog extends StatefulWidget {
  final List<Folder> availableFolders;
  final List<Folder> currentFolders;
  final ValueChanged<List<Folder>> onConfirm;

  const _FolderMembershipDialog({
    required this.availableFolders,
    required this.currentFolders,
    required this.onConfirm,
  });

  @override
  State<_FolderMembershipDialog> createState() =>
      _FolderMembershipDialogState();
}

class _FolderMembershipDialogState extends State<_FolderMembershipDialog> {
  late Set<Folder> _selected;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.currentFolders);
  }

  List<Folder> get _filteredFolders {
    if (_searchQuery.isEmpty) return widget.availableFolders;
    final query = _searchQuery.toLowerCase();
    return widget.availableFolders
        .where((f) => f.title.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Folders"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search folders...",
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredFolders.length,
                itemBuilder: (context, index) {
                  final folder = _filteredFolders[index];
                  return CheckboxListTile(
                    title: Text(folder.title),
                    value: _selected.contains(folder),
                    onChanged: (selected) {
                      setState(() {
                        if (selected!) {
                          _selected.add(folder);
                        } else {
                          _selected.remove(folder);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () {
            widget.onConfirm(_selected.toList());
            Navigator.pop(context);
          },
          child: const Text("Done"),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared InfoSection
// ---------------------------------------------------------------------------

class _InfoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
