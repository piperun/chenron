import "package:flutter/material.dart";
import "package:database/main.dart";

import "package:chenron/utils/validation/tag_validator.dart";

class TagsSection extends StatefulWidget {
  final List<Tag> tags;
  final bool isEditing;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;

  const TagsSection({
    super.key,
    required this.tags,
    required this.isEditing,
    required this.onTagAdded,
    required this.onTagRemoved,
  });

  @override
  State<TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<TagsSection> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleAddTag() {
    final parts = _controller.text
        .split(",")
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return;

    for (final tag in parts) {
      final validationError = TagValidator.validateTag(tag);
      if (validationError != null) {
        setState(() => _errorText = validationError);
        return;
      }
      if (widget.tags.any((t) => t.name == tag)) {
        setState(() => _errorText = "Tag '$tag' already exists");
        return;
      }
    }

    for (final tag in parts) {
      widget.onTagAdded(tag);
    }
    _controller.clear();
    setState(() => _errorText = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InfoSection(
      title: "Tags",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isEditing) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "tag1, tag2, tag3",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.tag),
                      errorText: _errorText,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _handleAddTag(),
                    onChanged: (_) {
                      if (_errorText != null) {
                        setState(() => _errorText = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _handleAddTag,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (widget.tags.isEmpty)
            Text(
              "No tags",
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.tags.map((tag) {
                if (widget.isEditing) {
                  return InputChip(
                    label: Text("#${tag.name}"),
                    onDeleted: () => widget.onTagRemoved(tag.id),
                    deleteIconColor: theme.colorScheme.error,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: theme.colorScheme.secondary
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return ReadOnlyTagChip(tag: tag);
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class ReadOnlyTagChip extends StatelessWidget {
  final Tag tag;

  const ReadOnlyTagChip({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color baseColor =
        tag.color != null ? Color(tag.color!) : colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: baseColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tag, size: 12, color: baseColor),
          const SizedBox(width: 4),
          Text(
            tag.name,
            style: TextStyle(
              fontSize: 11,
              color: baseColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const InfoSection({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
