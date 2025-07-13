import "package:chenron/core/theme/controller/theme_controller.dart";
import "package:signals/signals.dart";

final Signal<ThemeController> themeControllerSignal =
    signal(initializeThemeController());

ThemeController initializeThemeController() {
  ThemeController controller = ThemeController();
  controller.initialize();
  return controller;
}
