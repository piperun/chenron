import 'package:vibe/src/theme.dart';

/// Simple registry for [VibeTheme] instances, keyed by [VibeTheme.id].
class VibeRegistry {
  final Map<String, VibeTheme> _themes = <String, VibeTheme>{};

  /// Registers a theme. Overwrites any existing theme with the same id.
  void register(VibeTheme theme) {
    _themes[theme.id] = theme;
  }

  /// Retrieves a theme by [id], or null if not found.
  VibeTheme? get(String id) => _themes[id];

  /// All registered themes.
  List<VibeTheme> get all => _themes.values.toList(growable: false);

  /// All registered theme ids.
  List<String> get ids => _themes.keys.toList(growable: false);

  /// Whether a theme with [id] is registered.
  bool contains(String id) => _themes.containsKey(id);

  /// Number of registered themes.
  int get length => _themes.length;
}
