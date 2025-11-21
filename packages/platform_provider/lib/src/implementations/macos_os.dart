import '../operating_system.dart';
import '../platform_resources.dart';

class MacOS extends OperatingSystem {
  @override
  bool get isDesktop => true;

  @override
  bool get isMobile => false;

  @override
  String get name => 'macOS';

  @override
  PlatformResources get resources => MacOSResources();
}

class MacOSResources extends PlatformResources {
  @override
  String get cacheDirectoryHint =>
      '/Users/yourname/Library/Caches/chenron_images';

  @override
  String get monolithExecutableName => 'monolith-mac';
}
