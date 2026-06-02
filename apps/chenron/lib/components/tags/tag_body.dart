import "package:flutter/material.dart";

class TagBody extends StatelessWidget {
  final Set<String> tags;
  const TagBody({super.key, required this.tags});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tags",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TagsList(tags: tags),
            ],
          )),
    );
  }
}

class TagsList extends StatelessWidget {
  final Set<String> tags;
  const TagsList({super.key, required this.tags});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map((tag) => Chip(
                label: Text(
                  tag,
                  style: TextStyle(color: colorScheme.onSecondaryContainer),
                ),
                backgroundColor: colorScheme.secondaryContainer,
              ))
          .toList(),
    );
  }
}

