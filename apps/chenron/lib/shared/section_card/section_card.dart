import "package:flutter/material.dart";

/// A card with optional header elements and children content.
///
/// Recommended text styles:
/// - title: `theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)`
/// - subtitle: `theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)`
/// - description: `theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)`
/// - trailing: `theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)`
class CardSection extends StatelessWidget {
  final Text? title;
  final Text? subtitle;
  final Text? description;
  final Icon? sectionIcon;
  final Widget? trailing;
  final ThemeData? sectionTheme;
  final List<Widget> children;

  const CardSection({
    super.key,
    this.title,
    this.subtitle,
    this.description,
    this.sectionTheme,
    this.sectionIcon,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData sectionTheme = this.sectionTheme ?? Theme.of(context);
    final bool hasHeader = sectionIcon != null || title != null || subtitle != null || description != null || trailing != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasHeader) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (sectionIcon != null) ...[
                    Icon(sectionIcon?.icon,
                        size: 20, color: sectionTheme.colorScheme.primary),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null) title!,
                        if (subtitle != null) ...[
                          if (title != null) const SizedBox(height: 4),
                          subtitle!,
                        ],
                        if (description != null) ...[
                          if (title != null || subtitle != null) const SizedBox(height: 4),
                          description!,
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!,
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

