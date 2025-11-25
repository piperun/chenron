import "dart:collection";

/// Generic options pattern for feature flags
///
/// Used across database operations, search features, and other configurable components.
/// This pattern allows enabling specific features through an enum-based set.
///
/// Example:
/// ```dart
/// enum MyFeature { featureA, featureB }
///
/// // Enable specific features
/// const options = IncludeOptions<MyFeature>({MyFeature.featureA});
///
/// // Check if feature is enabled
/// if (options.has(MyFeature.featureA)) {
///   // Feature-specific logic
/// }
/// ```
class IncludeOptions<T extends Enum> {
  final Set<T> options;

  const IncludeOptions(this.options);

  IncludeOptions.unmodifiable(Set<T> options)
      : options = UnmodifiableSetView(options);

  const IncludeOptions.empty() : options = const {};

  /// Check if a specific option is enabled
  bool has(T option) => options.contains(option);
}
