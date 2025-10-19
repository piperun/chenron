import "dart:async";

import "package:chenron/shared/search/suggestion_builder.dart";
import "package:chenron/shared/search/search_history.dart";
import "package:chenron/shared/search/search_controller.dart";
import "package:chenron/shared/search/search_features.dart";
import "package:chenron/shared/search/search_feature_manager.dart";
import "package:chenron/shared/patterns/include_options.dart";
import "package:chenron/shared/utils/debouncer.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:flutter/material.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";
import "package:url_launcher/url_launcher.dart";

/// Global search bar with suggestions, history, and navigation
///
/// By default, all features are enabled (debounce, history, suggestions, navigation).
/// Features can be customized using the [features] parameter.
class GlobalSearchBar extends StatefulWidget {
  final IncludeOptions<SearchFeature> features;

  // Feature-specific configuration
  final Duration debounceDuration;
  final String? historyKey;
  final int maxHistoryItems;

  const GlobalSearchBar({
    super.key,
    this.features = const IncludeOptions<SearchFeature>({
      SearchFeature.debounce,
      SearchFeature.history,
      SearchFeature.suggestions,
      SearchFeature.navigation,
    }),
    this.debounceDuration = const Duration(milliseconds: 300),
    this.historyKey = "global_search",
    this.maxHistoryItems = 10,
  });

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  final SearchController _searchController = SearchController();
  final SearchBarController _queryController = SearchBarController();
  late final SearchFeatureManager _featureManager;
  late final Debouncer<List<ListTile>>? _suggestionsDebouncer;

  List<ListTile> _lastSuggestions = [];
  List<SearchHistoryItem> _searchHistory = [];

  @override
  void initState() {
    super.initState();

    // Create feature manager
    _featureManager = SearchFeatureManager(
      features: widget.features,
      debounceDuration: widget.debounceDuration,
      historyKey: widget.historyKey,
      maxHistoryItems: widget.maxHistoryItems,
    );
    _featureManager.setup(_queryController);

    // Create separate debouncer for suggestions if suggestions feature is enabled
    if (_featureManager.has(SearchFeature.suggestions) &&
        _featureManager.has(SearchFeature.debounce)) {
      _suggestionsDebouncer = Debouncer<List<ListTile>>(
        duration: widget.debounceDuration,
      );
    } else {
      _suggestionsDebouncer = null;
    }

    // Load history if history feature is enabled
    if (_featureManager.has(SearchFeature.history)) {
      _loadSearchHistory();
    }
  }

  Future<void> _loadSearchHistory() async {
    final history = await _featureManager.loadHistory();
    if (mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  @override
  void dispose() {
    _suggestionsDebouncer?.dispose();
    _featureManager.dispose(_queryController);
    _searchController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasHistory = _featureManager.has(SearchFeature.history);
    final hasSuggestions = _featureManager.has(SearchFeature.suggestions);

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
            if (hasHistory && _searchHistory.isNotEmpty)
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
            _queryController.value = value;
            if (value.isNotEmpty && hasSuggestions) {
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
          // Show history when search is empty (if history enabled)
          if (!hasHistory || _searchHistory.isEmpty) {
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

        // Only show suggestions if feature is enabled
        if (!hasSuggestions) {
          return [];
        }

        // Use debouncer if enabled, otherwise search immediately
        if (_suggestionsDebouncer != null) {
          final suggestions = await _suggestionsDebouncer.call(_handleSearch);
          if (suggestions != null) {
            _lastSuggestions = suggestions;
          }
        } else {
          _lastSuggestions = await _handleSearch();
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
      queryController: _queryController,
      onItemSelected: _saveToHistory,
    );
    return suggestionBuilder.buildSuggestions();
  }

  Future<void> _saveToHistory({
    required String type,
    required String id,
    required String title,
  }) async {
    if (_featureManager.has(SearchFeature.history)) {
      await _featureManager.saveQuery(
        type: type,
        id: id,
        title: title,
      );
      await _loadSearchHistory();
    }
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

    // Navigate based on item type (if navigation enabled)
    if (_featureManager.has(SearchFeature.navigation)) {
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
