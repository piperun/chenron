import "dart:async";

import "package:chenron/shared/search/suggestion_builder.dart";
import "package:chenron/shared/utils/debouncer.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:flutter/material.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";

class GlobalSearchBar extends StatefulWidget {
  const GlobalSearchBar({super.key});

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  final SearchController _searchController = SearchController();
  final _debouncer = Debouncer<List<ListTile>>();
  List<ListTile> _lastSuggestions = [];

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: _searchController,
      viewShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      builder: (context, controller) {
        return SearchBar(
          controller: controller,
          hintText: "Search across all items...",
          leading: const Icon(Icons.search),
          onChanged: (value) {
            if (value.isNotEmpty) {
              controller.openView();
            } else {
              controller.closeView(value);
            }
          },
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          elevation: const WidgetStatePropertyAll(0),
          side: WidgetStatePropertyAll(
            BorderSide(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        );
      },
      suggestionsBuilder: (context, controller) async {
        if (controller.text.isEmpty) {
          controller.closeView("");
          return [];
        }

        final suggestions = await _debouncer.call(_handleSearch);
        if (suggestions != null) {
          _lastSuggestions = suggestions;
        }
        return _lastSuggestions;
      },
    );
  }

  Future<List<ListTile>> _handleSearch() async {
    final db = locator.get<Signal<Future<AppDatabaseHandler>>>();
    final suggestionBuilder = GlobalSuggestionBuilder(
      db: db,
      context: context,
      controller: _searchController,
    );
    return suggestionBuilder.buildSuggestions();
  }
}
