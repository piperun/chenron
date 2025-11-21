import 'dart:io';
import 'package:flutter/foundation.dart';
import 'platform_resources.dart';
import 'implementations/windows_os.dart';
import 'implementations/macos_os.dart';
import 'implementations/linux_os.dart';
import 'implementations/android_os.dart';
import 'implementations/ios_os.dart';
import 'implementations/fuchsia_os.dart';
import 'implementations/unknown_os.dart';

/// Abstract class representing the current operating system.
abstract class OperatingSystem {
  /// Whether the current OS is a desktop platform.
  bool get isDesktop;

  /// Whether the current OS is a mobile platform.
  bool get isMobile;

  /// The name of the operating system.
  String get name;

  /// Platform-specific resources.
  PlatformResources get resources;

  static OperatingSystem? _current;

  /// Returns the current [OperatingSystem] implementation.
  static OperatingSystem get current {
    if (_current != null) return _current!;

    if (kIsWeb) {
      // Handle web if needed, or treat as unknown/generic for now
      _current = UnknownOS();
    } else if (Platform.isWindows) {
      _current = WindowsOS();
    } else if (Platform.isMacOS) {
      _current = MacOS();
    } else if (Platform.isLinux) {
      _current = LinuxOS();
    } else if (Platform.isAndroid) {
      _current = AndroidOS();
    } else if (Platform.isIOS) {
      _current = IOS();
    } else if (Platform.isFuchsia) {
      _current = FuchsiaOS();
    } else {
      _current = UnknownOS();
    }

    return _current!;
  }
}
