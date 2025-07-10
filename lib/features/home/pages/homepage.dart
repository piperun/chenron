import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/locator.dart";
import "package:chenron/utils/logger.dart";
import "package:chenron/shared/ui/search/searchbar.dart";
import "package:chenron/features/home/pages/root.dart";
import "package:chenron/features/theme/manager/theme_manager.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const GlobalSearchBar(),
        actions: const [DarkModeButton()],
      ),
      body: const RootPage(),
    );
  }
}

class DarkModeButton extends StatelessWidget {
  const DarkModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = locator.get<ThemeManager>();

    return Watch((context) {
      final currentMode = themeManager.themeModeSignal.value;
      final bool isCurrentlyDark = currentMode == ThemeMode.dark;
      final IconData iconData = currentMode == null
          ? Icons.brightness_auto_rounded
          : isCurrentlyDark
              ? Icons.dark_mode_rounded
              : Icons.light_mode_rounded;
      final String tooltip = currentMode == null
          ? "Loading theme..."
          : isCurrentlyDark
              ? "Switch to Light Mode"
              : "Switch to Dark Mode";

      return IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Icon(iconData, key: ValueKey(currentMode)),
        ),
        tooltip: tooltip,
        onPressed: currentMode == null
            ? null
            : () {
                loggerGlobal.info("DarkModeButton",
                    "Toggle pressed. Current mode: $currentMode. Setting dark to: ${!isCurrentlyDark}");
                themeManager.setDarkMode(isDark: !isCurrentlyDark);
              },
      );
    });
  }
}
