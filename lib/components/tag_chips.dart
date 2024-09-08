import 'package:flutter/material.dart';

class Chips extends StatelessWidget {
  final List<String> tags;
  final Function(String) onTagTap;

  const Chips({super.key, required this.tags, required this.onTagTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags
          .map((tag) => ActionChip(
                label: Text(tag),
                onPressed: () => onTagTap(tag),
              ))
          .toList(),
    );
  }
}
