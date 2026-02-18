import "package:flutter/material.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/components/copy_feedback_mixin.dart";

// URL bar with copy button and feedback animation
class ItemUrlBar extends StatefulWidget {
  final String url;

  const ItemUrlBar({
    super.key,
    required this.url,
  });

  @override
  State<ItemUrlBar> createState() => _ItemUrlBarState();
}

class _ItemUrlBarState extends State<ItemUrlBar> with CopyFeedbackMixin {
  @override
  void dispose() {
    disposeCopyFeedback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.link,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.url,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: "monospace",
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => handleCopy(widget.url),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: copied
                    ? theme.colorScheme.primaryContainer
                    : theme.cardColor,
                border: Border.all(
                  color:
                      copied ? theme.colorScheme.primary : theme.dividerColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (copied) ...[
                    Icon(
                      Icons.check,
                      size: 10,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    copied ? "copied!" : "copy",
                    style: TextStyle(
                      fontSize: 10,
                      color: copied
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: copied ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
