import "package:flutter/material.dart";
import "package:vibe/vibe.dart";

/// Single-line settings row that shows a cached stat (size, count, ...) with
/// a destructive "clear"-style action button on the right.
class StatsActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Future<int> future;
  final String Function(int value) formatValue;
  final String buttonLabel;
  final VoidCallback onClear;

  const StatsActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.future,
    required this.formatValue,
    required this.buttonLabel,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color
                    ?.withValues(alpha: 0.7),
              ),
            ),
            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                final value = snapshot.data;
                return Text(
                  value != null ? formatValue(value) : "...",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ],
        ),
        const Spacer(),
        NierMinorButton(
          label: buttonLabel,
          icon: Icons.delete_outline,
          destructive: true,
          onPressed: onClear,
        ),
      ],
    );
  }
}
