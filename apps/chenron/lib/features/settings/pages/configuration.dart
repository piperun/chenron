import "package:flutter/material.dart";
import "dart:async";
import "package:signals/signals_flutter.dart";

import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/features/settings/models/settings_category.dart";
import "package:chenron/features/settings/ui/settings_content_panel.dart";
import "package:chenron/locator.dart";
import "package:app_logger/app_logger.dart";

class ConfigPage extends StatefulWidget {
  final SettingsCategory selectedCategory;

  const ConfigPage({
    super.key,
    required this.selectedCategory,
  });

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final ConfigController _controller = locator.get<ConfigController>();

  @override
  void initState() {
    super.initState();
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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Stay"),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Discard"),
          ),
        ],
      ),
    );
    return shouldDiscard ?? false;
  }

  Future<void> _save() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text("Saving..."), duration: Duration(seconds: 60)));

    final success = await _controller.saveSettings();

    scaffoldMessenger.hideCurrentSnackBar();

    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (mounted) {
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
                "Error saving settings: ${_controller.error.peek() ?? 'Unknown error'}"),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        body: Watch(
          (context) {
            if (_controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (_controller.error.value != null) {
              return Center(child: Text("Error: ${_controller.error.value}"));
            } else {
              return SettingsContentPanel(
                category: widget.selectedCategory,
                controller: _controller,
                onSave: _save,
                isSaving: _controller.isLoading.value,
              );
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
