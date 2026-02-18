import "package:chenron/shared/labeled_text_field/labeled_text_field.dart";
import "package:chenron/shared/section_card/section_card.dart";
import "package:flutter/material.dart";
import "package:chenron/utils/validation/tag_validator.dart";

class TagSection extends StatefulWidget {
  final String? title;
  final String? description;
  final Set<String> tags;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;
  final String? keyPrefix;

  const TagSection({
    super.key,
    this.title,
    this.description,
    required this.tags,
    required this.onTagAdded,
    required this.onTagRemoved,
    this.keyPrefix,
  });

  @override
  State<TagSection> createState() => _TagSectionState();
}

class _TagSectionState extends State<TagSection> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() {
    final parts = _controller.text
        .split(",")
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      setState(() => _errorText = null);
      return;
    }

    // Validate all before adding any
    for (final tag in parts) {
      final validationError = TagValidator.validateTag(tag);
      if (validationError != null) {
        setState(() => _errorText = validationError);
        return;
      }
      if (widget.tags.contains(tag)) {
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

    return CardSection(
      title: Text(
        widget.title ?? "Tags",
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      description: widget.description != null
          ? Text(
              widget.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      sectionIcon: const Icon(Icons.sell),
      children: [
        Row(
          children: [
            Expanded(
              child: LabeledTextField(
                key: widget.keyPrefix != null
                    ? Key("${widget.keyPrefix}_tag_input")
                    : null,
                controller: _controller,
                labelText: "Add tag",
                hintText: "tag1, tag2, tag3",
                icon: const Icon(Icons.tag),
                errorText: _errorText,
                onSubmitted: (_) => _addTag(),
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              key: widget.keyPrefix != null
                  ? Key("${widget.keyPrefix}_tag_add_button")
                  : null,
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
                key: widget.keyPrefix != null
                    ? Key("${widget.keyPrefix}_tag_chip_$tag")
                    : null,
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
    );
  }
}

