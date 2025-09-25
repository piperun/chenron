import 'package:vibe/src/types.dart';

/// Simple registry for theme variants.
class ThemeRegistry {
  final Map<ThemeId, ThemeVariants> _themes = <ThemeId, ThemeVariants>{};

  /// Registers a theme pair under [id].
  void register(ThemeId id, ThemeVariants variants) {
    _themes[id] = variants;
  }

  /// Retrieves a registered theme by [id], if any.
  ThemeVariants? get(ThemeId id) => _themes[id];

  /// Returns all registered theme ids.
  List<ThemeId> get ids => _themes.keys.toList(growable: false);
}
