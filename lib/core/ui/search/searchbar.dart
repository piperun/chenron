import "package:chenron/core/ui/search/suggestion_builder.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:flutter/material.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";

class GlobalSearchBar extends StatelessWidget {
  const GlobalSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      viewShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      builder: (context, controller) {
        return SearchBar(
          controller: controller,
          hintText: "Search across all items...",
          leading: const Icon(Icons.search),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onTap: () {
            controller.openView();
          },
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          elevation: const WidgetStatePropertyAll(0),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
        );
      },
      suggestionsBuilder: (context, controller) {
        final db = locator.get<Signal<Future<AppDatabaseHandler>>>();
        final suggestionBuilder = GlobalSuggestionBuilder(
          db: db,
          context: context,
          controller: controller,
        );
        return suggestionBuilder.buildSuggestions();
      },
    );
  }
}
