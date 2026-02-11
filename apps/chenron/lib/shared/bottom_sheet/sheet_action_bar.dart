import "package:flutter/material.dart";

/// Action bar for the bottom of a sheet — a row of buttons with a
/// top border separator.
///
/// [leading] is placed at the start (e.g. a "Create New" button).
/// [trailing] is placed at the end (e.g. Cancel + primary action).
class SheetActionBar extends StatelessWidget {
  final Widget? leading;
  final List<Widget> trailing;

  const SheetActionBar({
    super.key,
    this.leading,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          if (leading != null) leading!,
          const Spacer(),
          for (int i = 0; i < trailing.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            trailing[i],
          ],
        ],
      ),
    );
  }
}
