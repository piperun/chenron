import '../operating_system.dart';
import '../platform_resources.dart';

class AndroidOS extends OperatingSystem {
  @override
  bool get isDesktop => false;

  @override
  bool get isMobile => true;

  @override
  String get name => 'Android';

  @override
  PlatformResources get resources => AndroidResources();
}

class AndroidResources extends PlatformResources {
  @override
  String get cacheDirectoryHint => '/data/user/0/com.example.chenron/cache';

  @override
  String get monolithExecutableName =>
      'libmonolith.so'; // Or however it's packaged
}
