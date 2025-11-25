import "package:flutter/material.dart";

/// Container widget that provides the Card layout for the item section
class ItemSection extends StatelessWidget {
  final Widget child;

  const ItemSection({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

