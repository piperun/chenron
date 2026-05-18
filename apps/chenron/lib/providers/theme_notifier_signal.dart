import "dart:async";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:signals/signals.dart";

final Signal<ThemeNotifier> themeNotifierSignal =
    signal(initializeThemeNotifier());

ThemeNotifier initializeThemeNotifier() {
  final ThemeNotifier controller = ThemeNotifier();
  unawaited(controller.initialize());
  return controller;
}

