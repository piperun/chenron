import "package:flutter/material.dart";

class LinkPageHeader extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onSave;
  final bool hasEntries;

  const LinkPageHeader({
    super.key,
    required this.onClose,
    required this.onSave,
    required this.hasEntries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key("create_link_close_button"),
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: "Close",
          ),
          const SizedBox(width: 8),
          Text(
            "Add Links",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            key: const Key("create_link_header_save_button"),
            onPressed: hasEntries ? onSave : null,
            icon: const Icon(Icons.save, size: 18),
            label: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
