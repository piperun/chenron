import "dart:async";

import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/locator.dart";
import "package:chenron/shared/errors/user_error_message.dart";
import "package:chenron/shared/item_detail/item_detail_data.dart";
import "package:chenron/shared/item_detail/item_detail_service.dart";
import "package:chenron/shared/ui/folder_picker.dart";
import "package:chenron/shared/item_detail/components/detail_header.dart";
import "package:chenron/shared/item_detail/components/hero_section.dart";
import "package:chenron/shared/item_detail/components/details_table.dart";
import "package:chenron/shared/item_detail/components/tags_section.dart";

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
            DetailHeader(
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
                      HeroSection(data: _data!),
                      const Divider(height: 32),
                      DetailsTable(data: _data!),
                      const Divider(height: 32),
                      TagsSection(
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
