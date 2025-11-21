import '../operating_system.dart';
import '../platform_resources.dart';

class UnknownOS extends OperatingSystem {
  @override
  bool get isDesktop => false;

  @override
  bool get isMobile => false;

  @override
  String get name => 'Unknown';

  @override
  PlatformResources get resources => UnknownResources();
}

class UnknownResources extends PlatformResources {
  @override
  String get cacheDirectoryHint => '/path/to/cache';

  @override
  String get monolithExecutableName => 'monolith';
}
