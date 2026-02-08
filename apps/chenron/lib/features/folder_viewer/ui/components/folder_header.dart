import "package:database/main.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class FolderHeader extends StatelessWidget {
  final Folder folder;
  final List<Tag> tags;
  final int totalItems;
  final VoidCallback onBack;
  final VoidCallback onHome;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool isLocked;
  final VoidCallback onToggleLock;
  final ValueChanged<String>? onTagTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FolderHeader({
    super.key,
    required this.folder,
    this.tags = const [],
    required this.totalItems,
    required this.onBack,
    required this.onHome,
    this.isExpanded = true,
    required this.onToggle,
    this.isLocked = false,
    required this.onToggleLock,
    this.onTagTap,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return "Unknown";

    // Use system locale for date formatting with 24-hour time
    // Get the system locale (e.g., 'sv_SE' for Swedish)
    final systemLocale = Intl.systemLocale;
    final formatter = DateFormat("yyyy-MM-dd HH:mm", systemLocale);
    return formatter.format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionRow(
            onBack: onBack,
            onHome: onHome,
            onEdit: onEdit,
            onDelete: onDelete,
            isLocked: isLocked,
            onToggleLock: onToggleLock,
            isExpanded: isExpanded,
            onToggle: onToggle,
          ),

          const SizedBox(height: 16),

          // Folder title
          Text(
            folder.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          // Metadata row
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _MetaItem(
                icon: Icons.calendar_today,
                text: "Created: ${_formatDate(folder.createdAt)}",
              ),
              _MetaItem(
                icon: Icons.description,
                text: "$totalItems items",
              ),
            ],
          ),

          // Tags as interactive chips
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map((tag) => _TagChip(
                        tag: tag,
                        onTap:
                            onTagTap != null ? () => onTagTap!(tag.name) : null,
                      ))
                  .toList(),
            ),
          ],

          // Description (if exists)
          if (folder.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              folder.description,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onHome;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLocked;
  final VoidCallback onToggleLock;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ActionRow({
    required this.onBack,
    required this.onHome,
    this.onEdit,
    this.onDelete,
    required this.isLocked,
    required this.onToggleLock,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;

    return Row(
      children: [
        Material(
          color: foreground.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onHome,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.home,
                size: 18,
                color: foreground.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: foreground.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back,
                size: 18,
                color: foreground.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
        const Spacer(),
        if (onEdit != null)
          Material(
            color: foreground.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: foreground.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        if (onEdit != null) const SizedBox(width: 8),
        if (onDelete != null)
          Material(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.delete,
                  size: 20,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        if (onDelete != null) const SizedBox(width: 8),
        Material(
          color: foreground.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onToggleLock,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AnimatedSwitcher(
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
                  isLocked ? Icons.lock : Icons.lock_open,
                  key: ValueKey<bool>(isLocked),
                  size: 20,
                  color: foreground.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: foreground.withValues(alpha: isLocked ? 0.04 : 0.08),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: isLocked ? null : onToggle,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: foreground.withValues(alpha: isLocked ? 0.4 : 0.95),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatefulWidget {
  final Tag tag;
  final VoidCallback? onTap;

  const _TagChip({required this.tag, this.onTap});

  @override
  State<_TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<_TagChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.secondaryContainer;
    final hoverColor = theme.colorScheme.secondary.withValues(alpha: 0.2);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovering ? hoverColor : baseColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.secondary
                  .withValues(alpha: _hovering ? 0.9 : 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tag, size: 14, color: theme.colorScheme.secondary),
              const SizedBox(width: 6),
              Text(
                widget.tag.name,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: foreground.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: foreground.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
