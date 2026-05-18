import "dart:async";

import "package:app_logger/app_logger.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/models/settings_category.dart";
import "package:chenron/features/settings/ui/settings_content_panel.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/dialogs/confirm_dialog.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

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
  final SettingsCoordinator _coordinator = locator.get<SettingsCoordinator>();

  @override
  void initState() {
    super.initState();
    unawaited(_coordinator.initialize());
    loggerGlobal.info("ConfigPage", "Initialized SettingsCoordinator.");
  }

  Future<bool> _showDiscardDialog(BuildContext context) {
    return showConfirmDialog(
      context,
      title: "Discard Unsaved Changes?",
      message: "You have unsaved changes. Do you want to discard them and "
          "leave this page?",
      cancelLabel: "Stay",
      confirmLabel: "Discard",
      destructive: true,
      barrierDismissible: false,
    );
  }

  Future<void> _save() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text("Saving..."), duration: Duration(seconds: 60)));

    final success = await _coordinator.saveAll();

    scaffoldMessenger.hideCurrentSnackBar();

    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text("Settings saved"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
                "Error saving settings: ${_coordinator.error.peek() ?? 'Unknown error'}"),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final hasChanges = _coordinator.hasUnsavedChanges;
      final isLoading = _coordinator.isLoading.value;
      final error = _coordinator.error.value;

      return PopScope(
        canPop: !hasChanges,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) {
            loggerGlobal.fine(
                "ConfigPage", "Pop allowed as no unsaved changes.");
            return;
          }

          final navigator = Navigator.of(context);
          loggerGlobal.fine("ConfigPage",
              "Pop prevented due to unsaved changes. Showing dialog.");
          final confirmDiscard = await _showDiscardDialog(context);

          if (confirmDiscard) {
            loggerGlobal.info(
                "ConfigPage", "User confirmed discard via dialog.");
            await _coordinator.initialize();
            if (mounted) {
              navigator.pop();
            }
          } else {
            loggerGlobal.fine(
                "ConfigPage", "User cancelled discard via dialog. Staying.");
          }
        },
        child: Scaffold(
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(child: Text("Error: $error"))
                  : SettingsContentPanel(
                      category: widget.selectedCategory,
                      onSave: _save,
                      isSaving: isLoading,
                      hasUnsavedChanges: hasChanges,
                    ),
        ),
      );
    });
  }

  @override
  void dispose() {
    loggerGlobal.info("ConfigPage", "Disposing ConfigPage state.");
    super.dispose();
  }
}
