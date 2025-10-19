import "package:chenron/shared/patterns/include_options.dart";
import "package:chenron/shared/search/search_features.dart";
import "package:chenron/shared/search/search_controller.dart";
import "package:chenron/shared/search/search_history.dart";
import "package:chenron/shared/utils/debouncer.dart";
import "package:flutter/material.dart";

/// Manages search features through composition
///
/// This class handles setup and disposal of search features like debouncing
/// and history, following the composition pattern (similar to how RelationBuilder
/// handles database includes).
///
/// Example usage:
/// ```dart
/// final manager = SearchFeatureManager(
///   features: const SearchFeatures({SearchFeature.debounce}),
///   debounceDuration: Duration(milliseconds: 500),
/// );
///
/// manager.setup(controller, _onDebouncedChange);
/// // ...later
/// manager.dispose(controller, _onDebouncedChange);
/// ```
class SearchFeatureManager {
  final IncludeOptions<SearchFeature> features;
  final Duration debounceDuration;
  final String? historyKey;
  final int maxHistoryItems;

  Debouncer<void>? _debouncer;
  SearchHistoryManager? _historyManager;
  VoidCallback? _debouncedListener;

  SearchFeatureManager({
    required this.features,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.historyKey,
    this.maxHistoryItems = 10,
  });

  /// Setup enabled features
  ///
  /// [controller] The search bar controller to attach listeners to
  /// [onDebouncedChange] Optional callback for debounced changes
  void setup(
    SearchBarController controller, [
    VoidCallback? onDebouncedChange,
  ]) {
    // Setup debouncing
    if (has(SearchFeature.debounce)) {
      _debouncer = Debouncer<void>(duration: debounceDuration);

      if (onDebouncedChange != null) {
        _debouncedListener = () {
          _debouncer!.call(() async {
            onDebouncedChange();
          });
        };
        controller.textController.addListener(_debouncedListener!);
      }
    }

    // Setup history
    if (has(SearchFeature.history)) {
      _historyManager = SearchHistoryManager();
    }
  }

  /// Cleanup enabled features
  ///
  /// [controller] The search bar controller to detach listeners from
  /// [listener] Optional listener to remove (should match the one passed to setup)
  void dispose(
    SearchBarController controller, [
    VoidCallback? listener,
  ]) {
    if (_debouncer != null) {
      if (_debouncedListener != null) {
        controller.textController.removeListener(_debouncedListener!);
      }
      _debouncer!.dispose();
    }
  }

  /// Check if a specific feature is enabled
  bool has(SearchFeature feature) => features.options.contains(feature);

  /// Get the history manager (if history feature is enabled)
  SearchHistoryManager? get historyManager => _historyManager;

  /// Save a query to history (if history feature is enabled)
  Future<void> saveQuery({
    required String type,
    required String id,
    required String title,
  }) async {
    if (_historyManager != null) {
      await _historyManager!.saveHistoryItem(
        type: type,
        id: id,
        title: title,
      );
    }
  }

  /// Load search history (if history feature is enabled)
  Future<List<SearchHistoryItem>> loadHistory() async {
    if (_historyManager != null) {
      return await _historyManager!.loadHistory();
    }
    return [];
  }
}
