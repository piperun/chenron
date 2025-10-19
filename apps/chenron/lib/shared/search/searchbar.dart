import "dart:async";

import "package:chenron/shared/search/suggestion_builder.dart";
import "package:chenron/shared/search/search_history.dart";
import "package:chenron/shared/utils/debouncer.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:flutter/material.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";
import "package:url_launcher/url_launcher.dart";

class GlobalSearchBar extends StatefulWidget {
  const GlobalSearchBar({super.key});

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  final SearchController _searchController = SearchController();
  final _debouncer = Debouncer<List<ListTile>>();
  final _historyManager = SearchHistoryManager();
  List<ListTile> _lastSuggestions = [];
  List<SearchHistoryItem> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final history = await _historyManager.loadHistory();
    if (mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

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
          trailing: [
            if (_searchHistory.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: "Recent searches",
                onPressed: () {
                  if (controller.text.isEmpty) {
                    controller.openView();
                  }
                },
              ),
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              controller.openView();
            }
            // Don't close view here - let SearchAnchor handle it
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
          // Show history when search is empty
          if (_searchHistory.isEmpty) {
            return []; // Return empty list instead of closing view
          }
          return _searchHistory.map((historyItem) {
            return ListTile(
              leading: Icon(_getIconForType(historyItem.type)),
              title: Text(historyItem.title),
              onTap: () => _handleHistoryItemTap(historyItem),
            );
          }).toList();
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
      onItemSelected: _saveToHistory,
    );
    return suggestionBuilder.buildSuggestions();
  }

  Future<void> _saveToHistory({
    required String type,
    required String id,
    required String title,
  }) async {
    await _historyManager.saveHistoryItem(
      type: type,
      id: id,
      title: title,
    );
    await _loadSearchHistory();
  }

  void _handleHistoryItemTap(SearchHistoryItem item) async {
    _searchController.closeView("");
    
    // Update history with new timestamp
    await _saveToHistory(
      type: item.type,
      id: item.id,
      title: item.title,
    );

    if (!mounted) return;

    // Navigate based on item type
    switch (item.type) {
      case "folder":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderViewerPage(folderId: item.id),
          ),
        );
      case "link":
        final uri = Uri.parse(item.id); // For links, id is the URL
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      case "document":
        // TODO: Handle document opening
        break;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case "folder":
        return Icons.folder;
      case "link":
        return Icons.link;
      case "document":
        return Icons.description;
      default:
        return Icons.help_outline;
    }
  }
}
