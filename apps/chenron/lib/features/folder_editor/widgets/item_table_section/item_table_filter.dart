import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/folder_editor/widgets/item_section/item_section_controller.dart";

class ItemTableFilter extends StatelessWidget {
  final ItemSectionController controller;

  const ItemTableFilter({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Watch((context) => TextField(
          decoration: InputDecoration(
            hintText: "Search items...",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clearSearch,
                  )
                : null,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: controller.updateSearchQuery,
        ));
  }
}
