import "package:flutter/material.dart";
import "package:chenron/utils/validation/tag_validator.dart";

class LinkTagsSection extends StatefulWidget {
  final Set<String> tags;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;

  const LinkTagsSection({
    super.key,
    required this.tags,
    required this.onTagAdded,
    required this.onTagRemoved,
  });

  @override
  State<LinkTagsSection> createState() => _LinkTagsSectionState();
}

class _LinkTagsSectionState extends State<LinkTagsSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _controller.text.trim().toLowerCase();
    
    if (tag.isEmpty) return;
    
    // Validate using TagValidator
    final validationError = TagValidator.validateTag(tag);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Check for duplicates
    if (widget.tags.contains(tag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tag '$tag' already exists"),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    widget.onTagAdded(tag);
    _controller.clear();
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
            Text(
              "Global Tags",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Applied to all new URLs added to the table",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: "Add tag",
                      hintText: "Enter tag name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add"),
                ),
              ],
            ),
            if (widget.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.tags.map((tag) {
                  return InputChip(
                    label: Text("#$tag"),
                    onDeleted: () => widget.onTagRemoved(tag),
                    deleteIconColor: theme.colorScheme.error,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
