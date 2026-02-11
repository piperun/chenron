import "package:flutter/material.dart";

/// Builder that receives the [ScrollController] from the
/// [DraggableScrollableSheet] so the body can attach it to a scrollable.
typedef SheetBodyBuilder = Widget Function(ScrollController scrollController);

/// A standardized scaffold for draggable bottom sheets.
///
/// Provides the common structure: drag handle, header with icon/title/close,
/// divider, content area, and an action bar at the bottom.
///
/// The [bodyBuilder] receives the sheet's [ScrollController] which should be
/// attached to the primary scrollable widget inside the body.
class BottomSheetScaffold extends StatelessWidget {
  final IconData headerIcon;
  final String title;
  final VoidCallback onClose;
  final SheetBodyBuilder bodyBuilder;
  final Widget actions;

  const BottomSheetScaffold({
    super.key,
    required this.headerIcon,
    required this.title,
    required this.onClose,
    required this.bodyBuilder,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return _SheetContainer(
          child: Column(
            children: [
              const _Handle(),
              _Header(
                icon: headerIcon,
                title: title,
                onClose: onClose,
              ),
              const Divider(height: 1),
              Expanded(child: bodyBuilder(scrollController)),
              actions,
            ],
          ),
        );
      },
    );
  }
}

class _SheetContainer extends StatelessWidget {
  final Widget child;

  const _SheetContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
      child: child,
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
}

class _Header extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onClose;

  const _Header({
    required this.icon,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: "Close",
          ),
        ],
      ),
    );
  }
}
