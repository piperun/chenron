import '../operating_system.dart';
import '../platform_resources.dart';

class FuchsiaOS extends OperatingSystem {
  @override
  bool get isDesktop => false; // Assuming mostly embedded/mobile-like for now

  @override
  bool get isMobile => true;

  @override
  String get name => 'Fuchsia';

  @override
  PlatformResources get resources => FuchsiaResources();
}

class FuchsiaResources extends PlatformResources {
  @override
  String get cacheDirectoryHint => '/cache';

  @override
  String get monolithExecutableName => 'monolith';
}
