import 'package:flutter/material.dart';
import 'package:chenron/database/database.dart';

class TagSearchBar extends StatelessWidget {
  final Stream<List<Tag>> tagsStream;
  final Function(String) onTagSelected;
  final Function(String) onTagUnselected;
  final Set<String> selectedTags;

  const TagSearchBar({
    super.key,
    required this.tagsStream,
    required this.onTagSelected,
    required this.onTagUnselected,
    required this.selectedTags,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Tag>>(
      stream: tagsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final tags = snapshot.data ?? [];
        return Wrap(
          spacing: 8,
          children: tags.map((tag) => _buildTagChip(tag)).toList(),
        );
      },
    );
  }

  Widget _buildTagChip(Tag tag) {
    final isSelected = selectedTags.contains(tag.name);
    return FilterChip(
      label: Text(tag.name),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onTagSelected(tag.name);
        } else {
          onTagUnselected(tag.name);
        }
      },
    );
  }
}
