import "package:flutter/material.dart";
import "package:chenron/features/create/link/notifiers/create_link_notifier.dart";

class LinkInputSection extends StatefulWidget {
  final InputMode mode;
  final ValueChanged<InputMode> onModeChanged;
  final ValueChanged<String> onAddSingle;
  final ValueChanged<String> onAddBulk;

  const LinkInputSection({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.onAddSingle,
    required this.onAddBulk,
  });

  @override
  State<LinkInputSection> createState() => _LinkInputSectionState();
}

class _LinkInputSectionState extends State<LinkInputSection> {
  final TextEditingController _singleController = TextEditingController();
  final TextEditingController _bulkController = TextEditingController();

  @override
  void dispose() {
    _singleController.dispose();
    _bulkController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    if (widget.mode == InputMode.single) {
      final text = _singleController.text.trim();
      if (text.isNotEmpty) {
        widget.onAddSingle(text);
        _singleController.clear();
      }
    } else {
      final text = _bulkController.text;
      if (text.trim().isNotEmpty) {
        widget.onAddBulk(text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ModeSwitcher(
                  mode: widget.mode,
                  onModeChanged: widget.onModeChanged,
                ),
                if (widget.mode == InputMode.bulk)
                  Text(
                    "Tip: Use '| tag1, tag2' or '#tag1 #tag2' for inline tags",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.mode == InputMode.single
                  ? _SingleInput(
                      controller: _singleController,
                      onAdd: _handleAdd,
                    )
                  : _BulkInput(
                      controller: _bulkController,
                      onAdd: _handleAdd,
                      onClear: () => _bulkController.clear(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  final InputMode mode;
  final ValueChanged<InputMode> onModeChanged;

  const _ModeSwitcher({
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeButton(
            label: "Single",
            isActive: mode == InputMode.single,
            onTap: () => onModeChanged(InputMode.single),
          ),
          _ModeButton(
            label: "Bulk",
            isActive: mode == InputMode.bulk,
            onTap: () => onModeChanged(InputMode.bulk),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isActive
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SingleInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const _SingleInput({
    required this.controller,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey("single"),
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "URL",
              hintText: "https://example.com | tag1, tag2",
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Add"),
        ),
      ],
    );
  }
}

class _BulkInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  final VoidCallback onClear;

  const _BulkInput({
    required this.controller,
    required this.onAdd,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("bulk"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "URLs (one per line)",
            hintText: "https://example.com | tag1, tag2\nhttps://another.com #tag1 #tag2\n# Lines starting with # are comments",
            border: OutlineInputBorder(),
          ),
          maxLines: 8,
          style: const TextStyle(fontFamily: "monospace"),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final lines = value.text.split("\n").where((l) => l.trim().isNotEmpty).length;
                return Text(
                  "$lines line${lines != 1 ? 's' : ''}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                );
              },
            ),
            Row(
              children: [
                TextButton(
                  onPressed: onClear,
                  child: const Text("Clear"),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text("Parse & Add"),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
