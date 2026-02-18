import "package:flutter/material.dart";
import "package:database/models/document_file_type.dart";

import "package:chenron/shared/item_detail/item_detail_data.dart";
import "package:chenron/shared/item_detail/components/type_chip.dart";

class DocumentHero extends StatelessWidget {
  final ItemDetailData data;

  const DocumentHero({super.key, required this.data});

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
            TypeChip(type: data.itemType),
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
