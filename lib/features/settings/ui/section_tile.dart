import 'package:flutter/material.dart';

class SectionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final bool expanded;

  const SectionTile({
    Key? key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.expanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        if (expanded)
          ...children
        else
          ExpansionTile(
            title: const Text("Show options"),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            children: children,
          ),
        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }
}
