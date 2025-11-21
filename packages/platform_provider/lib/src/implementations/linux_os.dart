import '../operating_system.dart';
import '../platform_resources.dart';

class LinuxOS extends OperatingSystem {
  @override
  bool get isDesktop => true;

  @override
  bool get isMobile => false;

  @override
  String get name => 'Linux';

  @override
  PlatformResources get resources => LinuxResources();
}

class LinuxResources extends PlatformResources {
  @override
  String get cacheDirectoryHint => '/home/yourname/.cache/chenron_images';

  @override
  String get monolithExecutableName => 'monolith-gnu-linux';
}
