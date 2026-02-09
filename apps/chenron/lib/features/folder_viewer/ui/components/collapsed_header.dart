import "package:flutter/material.dart";
import "package:database/main.dart";

class CollapsedHeader extends StatelessWidget {
  final Folder folder;
  final bool isHeaderLocked;
  final bool isHeaderExpanded;
  final VoidCallback onBack;
  final VoidCallback onHome;
  final VoidCallback onToggleLock;

  const CollapsedHeader({
    super.key,
    required this.folder,
    required this.isHeaderLocked,
    required this.isHeaderExpanded,
    required this.onBack,
    required this.onHome,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.home, color: foreground),
            onPressed: onHome,
          ),
          IconButton(
            icon: Icon(Icons.arrow_back, color: foreground),
            onPressed: onBack,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              folder.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: foreground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: Icon(
                isHeaderLocked ? Icons.lock : Icons.lock_open,
                key: ValueKey<bool>(isHeaderLocked),
                color: foreground,
              ),
            ),
            onPressed: onToggleLock,
          ),
          Icon(
            isHeaderExpanded ? Icons.expand_less : Icons.expand_more,
            color: foreground.withValues(alpha: isHeaderLocked ? 0.4 : 1.0),
          ),
        ],
      ),
    );
  }
}
