import "package:flutter/material.dart";

class PickerSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;

  const PickerSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = "Search...",
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        isDense: true,
      ),
    );
  }
}
