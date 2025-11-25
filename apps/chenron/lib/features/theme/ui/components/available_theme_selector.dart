import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:logger/logger.dart";

class AvailableThemeSelector extends StatelessWidget {
  final ConfigController controller;

  const AvailableThemeSelector({
    super.key,
    required this.controller,
  });

  static const EdgeInsets _contentPadding = EdgeInsets.all(16.0);
  static const EdgeInsets _dropdownPadding =
      EdgeInsets.symmetric(vertical: 8.0);

  @override
  Widget build(BuildContext context) {
    loggerGlobal.fine("AvailableThemeSelector", "Build method called.");

    final available = controller.availableThemes.watch(context);
    final selected = controller.selectedThemeChoice.watch(context);
    final isLoading = controller.isLoading.watch(context);
    final error = controller.error.watch(context);

    loggerGlobal.fine("AvailableThemeSelector",
        "State: isLoading=$isLoading, error=$error, availableThemes=${available.length}, selectedChoice=${selected?.key}");

    if (isLoading && available.isEmpty) {
      loggerGlobal.fine("AvailableThemeSelector", "Rendering Loading state.");
      return const Padding(
        padding: _contentPadding,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      loggerGlobal.warning(
          "AvailableThemeSelector", "Rendering Error state: $error");
      return Padding(
        padding: _contentPadding,
        child: Center(
          child: Text(
            "Error loading themes: $error",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    if (available.isEmpty) {
      loggerGlobal.fine("AvailableThemeSelector",
          "Rendering Empty state (no themes available).");
      return const Padding(
        padding: _contentPadding,
        child: Center(
          child: Text(
            "No themes available.", // Simplified message
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    loggerGlobal.fine("AvailableThemeSelector",
        "Rendering DropdownMenu (M3) with value: ${selected?.key}");

    return Padding(
      padding: _dropdownPadding,
      child: DropdownMenu<ThemeChoice>(
        label: const Text("Select Theme"),
        expandedInsets: EdgeInsets.zero,
        initialSelection: selected,
        dropdownMenuEntries: [
          for (final choice in available)
            DropdownMenuEntry<ThemeChoice>(
              value: choice,
              label: choice.name,
            )
        ],
        onSelected: (ThemeChoice? newValue) {
          loggerGlobal.info("AvailableThemeSelector",
              "DropdownMenu onSelected: New value selected: ${newValue?.key}");
          controller.updateSelectedTheme(newValue);
        },
      ),
    );
  }
}

