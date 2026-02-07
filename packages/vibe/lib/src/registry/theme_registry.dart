import 'package:vibe/src/spec/theme_spec.dart';
import 'package:vibe/src/validation/theme_validator.dart';

/// Exception thrown when theme registration fails
class ThemeRegistrationException implements Exception {
  /// Creates a [ThemeRegistrationException] with the given [message].
  ThemeRegistrationException(this.message);

  /// Description of why registration failed.
  final String message;

  @override
  String toString() => 'ThemeRegistrationException: $message';
}

/// Registry for theme specifications with optional validation
class ThemeRegistry<T extends ThemeSpec> {

  /// Creates a registry with an optional [validator] for theme compliance.
  ThemeRegistry({ThemeValidator? validator}) : _validator = validator;
  final Map<ThemeId, T> _themes = <ThemeId, T>{};
  final ThemeValidator? _validator;

  /// Register a theme with optional validation
  void register(T spec, {bool validate = true}) {
    if (validate && _validator != null) {
      final ThemeVariants variants = spec.build();
      final ValidationResult result = _validator.validate(variants);

      if (result is ValidationFailure) {
        throw ThemeRegistrationException(
          'Theme "${spec.id.value}" failed validation: ${result.errors.join(', ')}',
        );
      }
    }

    _themes[spec.id] = spec;
  }

  /// Get a theme by ID
  T? get(ThemeId id) => _themes[id];

  /// Get all registered themes
  List<T> getAll() => _themes.values.toList(growable: false);

  /// Get all registered theme IDs
  List<ThemeId> get ids => _themes.keys.toList(growable: false);

  /// Check if a theme is registered
  bool contains(ThemeId id) => _themes.containsKey(id);

  /// Get the number of registered themes
  int get length => _themes.length;

  /// Search themes by tags
  List<T> search({List<String> tags = const <String>[]}) {
    if (tags.isEmpty) {
      return getAll();
    }

    return _themes.values
        .where((T spec) =>
            tags.any((String tag) => spec.metadata.tags.contains(tag)))
        .toList(growable: false);
  }

  /// Get all theme metadata without building themes
  List<ThemeMetadata> getMetadataList() {
    return _themes.values
        .map((T spec) => spec.metadata)
        .toList(growable: false);
  }
}
