import 'package:flutter/material.dart';

/// Unique identifier for a theme
class ThemeId {

  /// Creates a [ThemeId] with the given string [value].
  const ThemeId(this.value);

  /// The unique string identifier.
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemeId && other.runtimeType == runtimeType && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ThemeId($value)';
}

/// Metadata describing a theme
class ThemeMetadata {

  /// Creates theme metadata with a required [name] and optional details.
  const ThemeMetadata({
    required this.name,
    this.description = '',
    this.author,
    this.version,
    this.tags = const <String>[],
  });

  /// Display name of the theme.
  final String name;

  /// Brief description of the theme.
  final String description;

  /// Theme author or creator.
  final String? author;

  /// Semantic version string.
  final String? version;

  /// Searchable tags for categorisation.
  final List<String> tags;

  @override
  String toString() => 'ThemeMetadata(name: $name, tags: $tags)';
}

/// A pair of Material ThemeData for light and dark variants
typedef ThemeVariants = ({ThemeData light, ThemeData dark});

/// Contract that all themes must fulfill
abstract class ThemeSpec {
  /// Unique identifier for this theme
  ThemeId get id;

  /// Human-readable metadata
  ThemeMetadata get metadata;

  /// Build the light and dark theme variants
  /// This is the only method that must be implemented
  ThemeVariants build();
}
