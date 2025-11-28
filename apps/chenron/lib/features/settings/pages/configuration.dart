import "package:flutter/material.dart";
import "dart:async";
import "package:signals/signals_flutter.dart";

import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/features/settings/ui/archive/archive_settings.dart";
import "package:chenron/features/settings/ui/cache/cache_settings.dart";
import "package:chenron/features/settings/ui/display/display_settings.dart";
import "package:chenron/features/theme/pages/theme_settings.dart";
import "package:chenron/locator.dart";
import "package:logger/logger.dart";

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  // Get the controller instance from the locator
  final ConfigController _controller = locator.get<ConfigController>();

  @override
  void initState() {
    super.initState();
    // Initialize the controller when the page loads
    // This fetches the config, themes, and sets initial state signals
    unawaited(_controller.initialize());
    loggerGlobal.info("ConfigPage", "Initialized ConfigController.");
  }

  Future<bool> _showDiscardDialog(BuildContext context) async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Discard Unsaved Changes?"),
        content: const Text(
            "You have unsaved changes. Do you want to discard them and leave this page?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Stay
            child: const Text("Stay"),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true), // Discard
            child: const Text("Discard"),
          ),
        ],
      ),
    );
    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Watch the controller's hasUnsavedChanges signal for PopScope
    final hasChanges = _controller.hasUnsavedChanges();

    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          loggerGlobal.fine("ConfigPage", "Pop allowed as no unsaved changes.");
          return;
        }

        final navigator = Navigator.of(context);
        loggerGlobal.fine("ConfigPage",
            "Pop prevented due to unsaved changes. Showing dialog.");
        final confirmDiscard = await _showDiscardDialog(context);

        if (confirmDiscard) {
          loggerGlobal.info("ConfigPage", "User confirmed discard via dialog.");
          // Reset controller state by re-initializing (or call a specific discard method)
          await _controller.initialize();
          if (mounted) {
            navigator.pop();
          }
        } else {
          loggerGlobal.fine(
              "ConfigPage", "User cancelled discard via dialog. Staying.");
        }
      },
      child: Scaffold(
        // appBar: AppBar(title: const Text("Configuration")), // Optional
        // Use Watch to react to controller state changes (loading, error)
        body: Watch(
          (context) {
            // Check loading and error states from the controller
            if (_controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (_controller.error.value != null) {
              return Center(child: Text("Error: ${_controller.error.value}"));
            } else if (_controller.userConfig.value == null &&
                !_controller.isLoading.value) {
              // Handle case where loading finished but no config was found (and no error string set)
              loggerGlobal.warning(
                  "ConfigPage", "No user config found after initialization.");
              // You might want a specific UI here, or let SettingsBody handle null config
              // For now, let's proceed to SettingsBody which might show defaults
              return SettingsBody(controller: _controller);
            } else {
              // If loaded successfully, display the main settings body
              return SettingsBody(controller: _controller);
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    loggerGlobal.info("ConfigPage", "Disposing ConfigPage state.");
    super.dispose();
  }
}

class SettingsBody extends StatelessWidget {
  final ConfigController controller;

  const SettingsBody({required this.controller, super.key});

  Future<void> _save(BuildContext context) async {
    // Show immediate feedback with a ScaffoldMessengerState reference
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text("Saving..."),
        duration: Duration(seconds: 60))); // Keep visible while saving

    final success = await controller.saveSettings();

    // Always hide the current snackbar first
    scaffoldMessenger.hideCurrentSnackBar();

    // Wait a brief moment to ensure the previous snackbar is dismissed
    await Future.delayed(const Duration(milliseconds: 100));

    // Show result feedback
    if (context.mounted) {
      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("Settings saved successfully!"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
                "Error saving settings: ${controller.error.peek() ?? 'Unknown error'}"),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                ThemeSettings(controller: controller),
                DisplaySettings(controller: controller),
                CacheSettings(controller: controller),
                ArchiveSettings(controller: controller),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            // Watch the loading state to disable the button while saving
            child: Watch(
              (context) => SaveSettingsButton(
                // Disable button while controller is loading/saving
                onPressed:
                    controller.isLoading.value ? null : () => _save(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SaveSettingsButton extends StatelessWidget {
  final VoidCallback? onPressed; // Changed to VoidCallback? to allow disabling

  const SaveSettingsButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed:
            onPressed, // Theme controls appearance globally via ElevatedButtonTheme
        child: const Text("Save Settings"),
      ),
    );
  }
}
