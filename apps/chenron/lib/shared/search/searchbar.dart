import "package:chenron/shared/constants/durations.dart";
import "package:chenron/shared/search/search_controller.dart";
import "package:chenron/shared/search/search_features.dart";
import "package:chenron/shared/search/search_feature_manager.dart";
import "package:chenron/shared/search/suggestions_overlay.dart";
import "package:database/database.dart";
import "package:flutter/material.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";

/// Global search bar with suggestions, history, and navigation
///
/// By default, all features are enabled (debounce, history, suggestions, navigation).
/// Features can be customized using the [features] parameter.
class GlobalSearchBar extends StatefulWidget {
  final IncludeOptions<SearchFeature> features;
  final SearchBarController? externalController;

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
    this.externalController,
    this.debounceDuration = kDefaultDebounceDuration,
    this.historyKey = "global_search",
    this.maxHistoryItems = 10,
  });

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  late final SearchBarController _queryController;
  late final bool _ownsController;
  late final SearchFeatureManager _featureManager;

  @override
  void initState() {
    super.initState();

    // Use external controller if provided, otherwise create our own
    if (widget.externalController != null) {
      _queryController = widget.externalController!;
      _ownsController = false;
    } else {
      _queryController = SearchBarController();
      _ownsController = true;
    }

    // Create feature manager
    _featureManager = SearchFeatureManager(
      features: widget.features,
      debounceDuration: widget.debounceDuration,
      historyKey: widget.historyKey,
      maxHistoryItems: widget.maxHistoryItems,
    );
    _featureManager.setup(_queryController);
  }

  @override
  void dispose() {
    _featureManager.dispose(_queryController);
    // Only dispose controller if we own it
    if (_ownsController) {
      _queryController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasSuggestions = _featureManager.has(SearchFeature.suggestions);
    final db = locator.get<Signal<AppDatabaseHandler>>();

    return hasSuggestions
        ? SuggestionsOverlay(
            controller: _queryController,
            db: db,
            debounceDuration: widget.debounceDuration,
            onItemSelected: _saveToHistory,
            child: SearchBar(
              controller: _queryController.textController,
              hintText: "Search across all items...",
              leading: const Icon(Icons.search),
              onSubmitted: (value) {
                // Call the external onSubmitted if provided
                widget.externalController?.onSubmitted?.call(value);
              },
              trailing: [
                Watch(
                  (context) {
                    final hasQuery = _queryController.query.value.isNotEmpty;
                    return hasQuery
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: "Clear search",
                            onPressed: () {
                              _queryController.clear();
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ],
              onChanged: (value) {
                // Update query signal - this triggers real-time filtering
                _queryController.updateSignal(value);
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
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
            ),
          )
        : SearchBar(
            controller: _queryController.textController,
            hintText: "Search across all items...",
            leading: const Icon(Icons.search),
            onSubmitted: (value) {
              // Call the external onSubmitted if provided
              widget.externalController?.onSubmitted?.call(value);
            },
            trailing: [
              Watch(
                (context) {
                  final hasQuery = _queryController.query.value.isNotEmpty;
                  return hasQuery
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: "Clear search",
                          onPressed: () {
                            _queryController.clear();
                          },
                        )
                      : const SizedBox.shrink();
                },
              ),
            ],
            onChanged: (value) {
              // Update query signal - this triggers real-time filtering
              _queryController.updateSignal(value);
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
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
              ),
            ),
          );
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
    }
  }
}
