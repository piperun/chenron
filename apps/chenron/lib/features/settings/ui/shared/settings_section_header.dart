import "package:flutter/material.dart";

/// Section header for settings pages: large title + dimmed description
/// + a configurable gap before the section body.
///
/// Replaces the inline `Text(title, titleMedium) + SizedBox(8) +
/// Text(description, bodySmall@70%) + SizedBox(gapAfter)` pattern
/// that was repeated 12+ times across `backup_settings`,
/// `data_settings`, `cache_settings`, `display_settings`, and
/// `tag_management_settings`.
class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final String description;

  /// Vertical space below the description block. Defaults to 16.
  final double gapAfter;

  const SettingsSectionHeader({
    super.key,
    required this.title,
    required this.description,
    this.gapAfter = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: gapAfter),
      ],
    );
  }
}
