import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import 'package:chenron/features/settings/controller/config_controller.dart'; // Import controller and ThemeChoice
import "package:chenron/utils/logger.dart"; // Keep logger if needed

class AvailableThemeSelector extends StatelessWidget {
  final ConfigController controller; // Accept the controller

  const AvailableThemeSelector({
    super.key,
    required this.controller, // Require the controller
  });

  // Define consistent padding (can keep static)
  static const EdgeInsets _contentPadding = EdgeInsets.all(16.0);
  static const EdgeInsets _dropdownPadding =
      EdgeInsets.symmetric(vertical: 8.0);

  @override
  Widget build(BuildContext context) {
    // Add logging at the start of the build method if desired
    loggerGlobal.fine("AvailableThemeSelector", "Build method called.");

    // Watch necessary signals directly from the controller
    final available = controller.availableThemes.watch(context);
    final selected = controller.selectedThemeChoice.watch(context);
    final isLoading =
        controller.isLoading.watch(context); // Use controller's loading state
    final error =
        controller.error.watch(context); // Use controller's error state

    // Log the state read from signals
    loggerGlobal.fine("AvailableThemeSelector",
        "State: isLoading=$isLoading, error=$error, availableThemes=${available.length}, selectedChoice=${selected?.key}");

    // Build UI based on controller state
    if (isLoading && available.isEmpty) {
      // Show loading only if themes aren't loaded yet
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
            "Error loading themes: $error", // Display error from controller
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

    // --- Main Dropdown ---
    loggerGlobal.fine("AvailableThemeSelector",
        "Rendering DropdownButtonFormField with value: ${selected?.key}");
    return Padding(
      padding: _dropdownPadding, // Padding around the dropdown
      child: DropdownButtonFormField<ThemeChoice>(
        isExpanded: true,
        decoration: InputDecoration(
          labelText: "Select Theme",
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          hintText: "Select a theme", // Always show hint if items exist
        ),
        value:
            selected, // Use the ThemeChoice object from the controller signal
        // Check if selected value exists in items (DropdownButtonFormField handles mismatch gracefully)
        items:
            available.map<DropdownMenuItem<ThemeChoice>>((ThemeChoice choice) {
          return DropdownMenuItem<ThemeChoice>(
            value: choice, // The value is the ThemeChoice object itself
            child: Text(choice.name), // Display the theme name
          );
        }).toList(),
        onChanged: (ThemeChoice? newValue) {
          // Log when the selection changes
          loggerGlobal.info("AvailableThemeSelector",
              "Dropdown onChanged: New value selected: ${newValue?.key}");
          // Update the controller's selected theme signal
          controller.updateSelectedTheme(newValue);
        },
      ),
    );
  }
}
