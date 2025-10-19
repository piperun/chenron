import "package:flutter/material.dart";
import "package:signals/signals.dart";

/// A hybrid search controller that combines Flutter's TextEditingController
/// with signals for reactive search handling.
///
/// This allows:
/// - TextField to use the native controller
/// - Other components to watch the query signal reactively
class SearchBarController {
  final TextEditingController _textController = TextEditingController();
  final Signal<String> _query = signal("");

  SearchBarController() {
    _textController.addListener(() {
      _query.value = _textController.text;
    });
  }

  /// The underlying TextEditingController for TextField
  TextEditingController get textController => _textController;

  /// The reactive signal for other components to watch
  Signal<String> get query => _query;

  /// Current query value
  String get value => _query.value;

  /// Set the query programmatically
  set value(String newValue) {
    _textController.text = newValue;
    // Signal updates automatically via listener
  }

  /// Clear the search query
  void clear() {
    _textController.clear();
    // Signal updates automatically via listener
  }

  void dispose() {
    _textController.dispose();
    _query.dispose();
  }
}
