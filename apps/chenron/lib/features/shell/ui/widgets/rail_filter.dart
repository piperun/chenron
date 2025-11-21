import "package:flutter/material.dart";

class RailFilter extends StatelessWidget {
  final bool isExtended;
  final ValueChanged<String> onFilterChanged;

  const RailFilter({
    super.key,
    required this.isExtended,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!isExtended) {
      return IconButton(
        icon: const Icon(Icons.filter_list, size: 20),
        onPressed: () {},
        tooltip: "Filter folders",
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Filter folders...",
          prefixIcon: const Icon(Icons.filter_list, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          isDense: true,
        ),
        onChanged: onFilterChanged,
      ),
    );
  }
}
