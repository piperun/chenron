import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/components/item_card/item_utils.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:cache_manager/cache_manager.dart";

// Show detailed item info modal
void showItemInfoModal(BuildContext context, FolderItem item) {
  final url = ItemUtils.getUrl(item);
  
  showDialog(
    context: context,
    builder: (context) => ItemInfoModal(item: item, url: url),
  );
}

class ItemInfoModal extends StatelessWidget {
  final FolderItem item;
  final String? url;

  const ItemInfoModal({
    super.key,
    required this.item,
    this.url,
  });

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
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getTypeIcon(),
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Item Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: "Close",
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type
                    _InfoSection(
                      title: "Type",
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.type.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    if (item.type == FolderItemType.link && url != null && url!.isNotEmpty)
                      FutureBuilder<Map<String, dynamic>?>(
                        future: MetadataCache.get(url!),
                        builder: (context, snapshot) {
                          final title = snapshot.data?["title"] as String?;
                          if (title != null && title.isNotEmpty) {
                            return Column(
                              children: [
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
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                    // Description
                    if (item.type == FolderItemType.link && url != null && url!.isNotEmpty)
                      FutureBuilder<Map<String, dynamic>?>(
                        future: MetadataCache.get(url!),
                        builder: (context, snapshot) {
                          final description = snapshot.data?["description"] as String?;
                          if (description != null && description.isNotEmpty) {
                            return Column(
                              children: [
                                _InfoSection(
                                  title: "Description",
                                  child: Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                    // URL
                    if (item.type == FolderItemType.link && url != null && url!.isNotEmpty) ...[
                      _InfoSection(
                        title: "URL",
                        child: SelectableText(
                          url!,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "monospace",
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Domain
                      _InfoSection(
                        title: "Domain",
                        child: Text(
                          ItemUtils.getDomain(url!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Created date
                    if (item.createdAt != null) ...[
                      _InfoSection(
                        title: "Created",
                        child: Text(
                          _formatDateTime(item.createdAt!),
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tags section
                    _InfoSection(
                      title: "Tags",
                      child: _buildTagsSection(theme),
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

  IconData _getTypeIcon() {
    switch (item.type) {
      case FolderItemType.link:
        return Icons.link;
      case FolderItemType.document:
        return Icons.description;
      case FolderItemType.folder:
        return Icons.folder;
    }
  }

  Widget _buildTagsSection(ThemeData theme) {
    final tags = ItemUtils.buildTags(item);
    
    if (tags.isEmpty) {
      return Text(
        "No tags",
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return "Just now";
        }
        return "${difference.inMinutes}m ago";
      }
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "$weeks week${weeks > 1 ? 's' : ''} ago";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "$months month${months > 1 ? 's' : ''} ago";
    } else {
      final years = (difference.inDays / 365).floor();
      return "$years year${years > 1 ? 's' : ''} ago";
    }
  }
}

// Info section widget
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
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// Info chip widget
class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _InfoChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
