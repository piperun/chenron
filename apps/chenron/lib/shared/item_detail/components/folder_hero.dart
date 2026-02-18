import "dart:async";

import "package:flutter/material.dart";

import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/shared/item_detail/item_detail_data.dart";
import "package:chenron/shared/item_detail/components/type_chip.dart";

class FolderHero extends StatelessWidget {
  final ItemDetailData data;

  const FolderHero({super.key, required this.data});

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
            TypeChip(type: data.itemType),
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
