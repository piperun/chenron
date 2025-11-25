import "dart:async";
import "package:chenron/features/theme/state/theme_controller.dart";
import "package:signals/signals.dart";

final Signal<ThemeController> themeControllerSignal =
    signal(initializeThemeController());

ThemeController initializeThemeController() {
  final ThemeController controller = ThemeController();
  unawaited(controller.initialize());
  return controller;
}

