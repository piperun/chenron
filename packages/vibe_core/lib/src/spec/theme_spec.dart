import 'package:flutter/material.dart';

/// Unique identifier for a theme
class ThemeId {
  final String value;

  const ThemeId(this.value);

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
  final String name;
  final String description;
  final String? author;
  final String? version;
  final List<String> tags;

  const ThemeMetadata({
    required this.name,
    this.description = '',
    this.author,
    this.version,
    this.tags = const <String>[],
  });

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
