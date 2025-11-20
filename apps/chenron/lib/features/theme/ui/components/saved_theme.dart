// 1. Theme Selection Component
import "package:chenron/models/db_result.dart" show UserThemeResult;
import "package:flutter/material.dart";

class SavedThemeSelector extends StatelessWidget {
  final List<UserThemeResult> themes;
  final UserThemeResult? selectedTheme;
  final bool isLoading;
  final bool isParentCreating;
  final ValueChanged<UserThemeResult?> onThemeSelected;

  const SavedThemeSelector({
    super.key,
    required this.themes,
    required this.selectedTheme,
    required this.isLoading,
    required this.isParentCreating,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (themes.isEmpty && !isParentCreating) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.palette_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                "No saved themes found",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Use the 'Create New Theme' button below to make your first one.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // If themes are empty BUT parent is creating, show nothing or a minimal placeholder.
    // Showing nothing is often cleanest.
    if (themes.isEmpty && isParentCreating) {
      // Optionally return a SizedBox or an empty Container if you need to maintain layout space
      return const SizedBox.shrink(); // Renders nothing
    }

    // --- END MODIFIED LOGIC ---

    // Show the dropdown when themes exist (regardless of parent creation state)
    // You might want to disable the dropdown during creation if interaction is undesirable
    final bool enableDropdown =
        !isParentCreating; // Example: Disable during creation

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Select Saved Theme",
            border: const OutlineInputBorder(),
            // Optionally change appearance when disabled
            filled: !enableDropdown,
            fillColor: !enableDropdown
                ? Theme.of(context).disabledColor.withValues(alpha: 0.1)
                : null,
          ),
          initialValue: selectedTheme?.data.id,
          items: themes
              .map((theme) => DropdownMenuItem(
                    value: theme.data.id,
                    child: Text(theme.data.name),
                  ))
              .toList(),
          // Use null for onChanged when disabled
          onChanged: enableDropdown
              ? (value) {
                  if (value == null) {
                    onThemeSelected(null);
                  } else {
                    final selected =
                        themes.firstWhere((t) => t.data.id == value);
                    onThemeSelected(selected);
                  }
                }
              : null, // Disable onChanged callback
          hint: selectedTheme == null ? const Text("Select a theme") : null,
          // Style differently if disabled?
          // disabledHint: enableDropdown ? null : Text(selectedTheme?.data.name ?? "Select a theme"),
        ),
      ],
    );
  }
}
