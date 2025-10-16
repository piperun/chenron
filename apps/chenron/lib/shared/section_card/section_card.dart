import "package:flutter/material.dart";

class CardSection extends StatelessWidget {
  final String title;
  final String? description;
  final Icon? sectionIcon;
  final ThemeData? sectionTheme;
  final MainAxisAlignment mainAxisAlign;
  final List<Widget> children;

  const CardSection({
    super.key,
    required this.title,
    this.description,
    this.sectionTheme,
    this.sectionIcon,
    this.mainAxisAlign = MainAxisAlignment.start,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData sectionTheme = this.sectionTheme ?? Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: mainAxisAlign,
              children: [
                Icon(sectionIcon?.icon,
                    size: 20, color: sectionTheme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: sectionTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: sectionTheme.textTheme.bodySmall?.copyWith(
                  color: sectionTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
