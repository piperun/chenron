import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:database/database.dart";
import "package:database/main.dart";
import "package:signals/signals_flutter.dart";
import "package:url_launcher/url_launcher.dart" as url_launcher;

import "package:chenron/locator.dart";
import "package:chenron/components/favicon_display/favicon.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/shared/errors/user_error_message.dart";
import "package:chenron/shared/item_detail/item_detail_data.dart";
import "package:chenron/shared/item_detail/item_detail_service.dart";
import "package:chenron/shared/utils/time_formatter.dart";
import "package:chenron/shared/ui/folder_picker.dart";
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
          _error = userErrorMessage(e);
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroSection(data: _data!),
                      const Divider(height: 32),
                      _DetailsTable(data: _data!),
                      const Divider(height: 32),
                      _TagsSection(
                        tags: _data!.tags,
                        isEditing: _isEditing,
                        onTagAdded: _handleAddTag,
                        onTagRemoved: _handleRemoveTag,
                      ),
                      const SizedBox(height: 12),
                      FolderPicker(
                        initialFolders: _data!.parentFolders,
                        readOnly: !_isEditing,
                        allowEmpty: true,
                        onFoldersSelected: (folders) {
                          final currentIds =
                              _data!.parentFolders.map((f) => f.id).toSet();
                          final selectedIds =
                              folders.map((f) => f.id).toSet();
                          for (final id in selectedIds.difference(currentIds)) {
                            unawaited(_handleAddToFolder(id));
                          }
                          for (final id in currentIds.difference(selectedIds)) {
                            unawaited(_handleRemoveFromFolder(id));
                          }
                        },
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
// Hero section (type-specific primary info + actions)
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  final ItemDetailData data;

  const _HeroSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return switch (data.itemType) {
      FolderItemType.link => _LinkHero(data: data),
      FolderItemType.document => _DocumentHero(data: data),
      FolderItemType.folder => _FolderHero(data: data),
    };
  }
}

class _LinkHero extends StatefulWidget {
  final ItemDetailData data;

  const _LinkHero({required this.data});

  @override
  State<_LinkHero> createState() => _LinkHeroState();
}

class _LinkHeroState extends State<_LinkHero> {
  late Future<Map<String, dynamic>?> _metadataFuture;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _metadataFuture = widget.data.url != null
        ? MetadataFactory.getOrFetch(widget.data.url!)
        : Future.value(null);
  }

  Future<void> _handleRefreshMetadata() async {
    if (widget.data.url == null || _isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _metadataFuture = MetadataFactory.forceFetch(widget.data.url!);
    });
    await _metadataFuture;
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _handleOpenLink() async {
    if (widget.data.url == null) return;
    final uri = Uri.parse(widget.data.url!);
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri);
    }
  }

  void _handleCopyUrl() {
    if (widget.data.url == null) return;
    unawaited(Clipboard.setData(ClipboardData(text: widget.data.url!)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("URL copied to clipboard"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Domain row with favicon and type badge
        Row(
          children: [
            if (widget.data.url != null) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: Favicon(url: widget.data.url!),
              ),
              const SizedBox(width: 8),
            ],
            if (widget.data.domain != null)
              Expanded(
                child: Text(
                  widget.data.domain!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),
            _TypeChip(type: widget.data.itemType),
          ],
        ),
        const SizedBox(height: 12),

        // Metadata title + description
        FutureBuilder<Map<String, dynamic>?>(
          future: _metadataFuture,
          builder: (context, snapshot) {
            final title = snapshot.data?["title"] as String?;
            final description = snapshot.data?["description"] as String?;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title.isNotEmpty) ...[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (description != null && description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // Action buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _handleOpenLink,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text("Open Link"),
            ),
            OutlinedButton.icon(
              onPressed: _handleCopyUrl,
              icon: const Icon(Icons.copy, size: 16),
              label: const Text("Copy URL"),
            ),
            OutlinedButton.icon(
              onPressed: _isRefreshing ? null : _handleRefreshMetadata,
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 16),
              label: const Text("Refresh"),
            ),
          ],
        ),
      ],
    );
  }
}

class _FolderHero extends StatelessWidget {
  final ItemDetailData data;

  const _FolderHero({required this.data});

  void _handleOpenFolder(BuildContext context) {
    Navigator.of(context).pop();
    unawaited(Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderViewerPage(folderId: data.itemId),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color dot + type badge row
        Row(
          children: [
            if (data.color != null) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(data.color!),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Spacer(),
            _TypeChip(type: data.itemType),
          ],
        ),
        const SizedBox(height: 12),

        // Description
        if (data.description != null &&
            data.description!.isNotEmpty) ...[
          Text(
            data.description!,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color:
                  theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Contents summary
        Text(
          _formatContents(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Action button
        FilledButton.icon(
          onPressed: () => _handleOpenFolder(context),
          icon: const Icon(Icons.folder_open, size: 16),
          label: const Text("Open Folder"),
        ),
      ],
    );
  }

  String _formatContents() {
    final parts = <String>[];
    if (data.linkCount > 0) {
      parts.add(
          "${data.linkCount} ${data.linkCount == 1 ? 'link' : 'links'}");
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

class _DocumentHero extends StatelessWidget {
  final ItemDetailData data;

  const _DocumentHero({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge row
        Row(
          children: [
            const Spacer(),
            _TypeChip(type: data.itemType),
          ],
        ),
        const SizedBox(height: 12),

        // File type + size inline
        Row(
          children: [
            if (data.fileType != null)
              Container(
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
            if (data.fileType != null && data.fileSize != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "\u00B7",
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            if (data.fileSize != null)
              Text(
                _formatFileSize(data.fileSize!),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
          ],
        ),

        // File path
        if (data.filePath != null) ...[
          const SizedBox(height: 8),
          SelectableText(
            data.filePath!,
            style: TextStyle(
              fontSize: 13,
              fontFamily: "monospace",
              color:
                  theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    }
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  }
}

// ---------------------------------------------------------------------------
// Compact type chip
// ---------------------------------------------------------------------------

class _TypeChip extends StatelessWidget {
  final FolderItemType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
    );
  }
}

// ---------------------------------------------------------------------------
// Compact details table
// ---------------------------------------------------------------------------

class _DetailsTable extends StatelessWidget {
  final ItemDetailData data;

  const _DetailsTable({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (data.createdAt != null)
          _DetailRow(
            label: "Created",
            child: Text(
              "${TimeFormatter.formatFull(data.createdAt)} (${TimeFormatter.formatRelative(data.createdAt)})",
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        if (data.updatedAt != null && data.updatedAt != data.createdAt)
          _DetailRow(
            label: "Updated",
            child: Text(
              "${TimeFormatter.formatFull(data.updatedAt)} (${TimeFormatter.formatRelative(data.updatedAt)})",
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        if (data.url != null)
          _DetailRow(
            label: "URL",
            child: SelectableText(
              data.url!,
              style: TextStyle(
                fontSize: 12,
                fontFamily: "monospace",
                color: theme.colorScheme.primary,
              ),
              maxLines: 2,
            ),
          ),
        if (data.domain != null)
          _DetailRow(
            label: "Domain",
            child: Text(
              data.domain!,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        if (data.archiveOrgUrl != null ||
            data.archiveIsUrl != null ||
            data.localArchivePath != null)
          _DetailRow(
            label: "Archives",
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (data.archiveOrgUrl != null)
                  _ArchiveBadge(
                    label: "archive.org",
                    url: data.archiveOrgUrl,
                  ),
                if (data.archiveIsUrl != null)
                  _ArchiveBadge(
                    label: "archive.is",
                    url: data.archiveIsUrl,
                  ),
                if (data.localArchivePath != null)
                  const _ArchiveBadge(label: "Local backup"),
              ],
            ),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _DetailRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ArchiveBadge extends StatelessWidget {
  final String label;
  final String? url;

  const _ArchiveBadge({required this.label, this.url});

  Future<void> _handleTap() async {
    if (url == null) return;
    final uri = Uri.tryParse(url!);
    if (uri != null) {
      await url_launcher.launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (url != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.open_in_new,
                size: 11,
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );

    if (url != null) {
      return InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(4),
        child: badge,
      );
    }
    return badge;
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
    final parts = _controller.text
        .split(",")
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return;

    for (final tag in parts) {
      final validationError = TagValidator.validateTag(tag);
      if (validationError != null) {
        setState(() => _errorText = validationError);
        return;
      }
      if (widget.tags.any((t) => t.name == tag)) {
        setState(() => _errorText = "Tag '$tag' already exists");
        return;
      }
    }

    for (final tag in parts) {
      widget.onTagAdded(tag);
    }
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
                      hintText: "tag1, tag2, tag3",
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
