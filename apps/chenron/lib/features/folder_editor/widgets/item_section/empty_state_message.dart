import 'package:flutter/material.dart';

/// Reusable empty state message widget for displaying when no items are present
class EmptyStateMessage extends StatelessWidget {
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateMessage({
    super.key,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Message
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // Optional action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
