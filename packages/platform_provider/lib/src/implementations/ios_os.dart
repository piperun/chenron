import '../operating_system.dart';
import '../platform_resources.dart';

class IOS extends OperatingSystem {
  @override
  bool get isDesktop => false;

  @override
  bool get isMobile => true;

  @override
  String get name => 'iOS';

  @override
  PlatformResources get resources => IOSResources();
}

class IOSResources extends PlatformResources {
  @override
  String get cacheDirectoryHint =>
      '/var/mobile/Containers/Data/Application/.../Library/Caches';

  @override
  String get monolithExecutableName =>
      'monolith'; // Not really applicable for iOS usually
}
