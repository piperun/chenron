/// Abstract class defining platform-specific resources (strings, values).
abstract class PlatformResources {
  /// Hint text displayed in the cache directory settings.
  String get cacheDirectoryHint;

  /// Name of the Monolith executable.
  String get monolithExecutableName;
}
