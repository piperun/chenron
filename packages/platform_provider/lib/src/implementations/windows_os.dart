import '../operating_system.dart';
import '../platform_resources.dart';

class WindowsOS extends OperatingSystem {
  @override
  bool get isDesktop => true;

  @override
  bool get isMobile => false;

  @override
  String get name => 'Windows';

  @override
  PlatformResources get resources => WindowsResources();
}

class WindowsResources extends PlatformResources {
  @override
  String get cacheDirectoryHint => r'C:\Users\YourName\AppData\Local\cache';

  @override
  String get monolithExecutableName => 'monolith.exe';
}
