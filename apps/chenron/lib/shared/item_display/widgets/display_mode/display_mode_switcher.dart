import "package:flutter/material.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";

/// Compact dropdown widget for switching between display modes
class DisplayModeSwitcher extends StatelessWidget {
  final DisplayMode selectedMode;
  final ValueChanged<DisplayMode> onModeChanged;

  const DisplayModeSwitcher({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  String _getModeLabel(DisplayMode mode) {
    switch (mode) {
      case DisplayMode.compact:
        return "Compact";
      case DisplayMode.standard:
        return "Standard";
      case DisplayMode.extended:
        return "Extended";
    }
  }

  IconData _getModeIcon(DisplayMode mode) {
    switch (mode) {
      case DisplayMode.compact:
        return Icons.view_compact;
      case DisplayMode.standard:
        return Icons.view_agenda;
      case DisplayMode.extended:
        return Icons.view_stream;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<DisplayMode>(
      initialValue: selectedMode,
      onSelected: onModeChanged,
      tooltip: "Display Mode",
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getModeIcon(selectedMode),
              size: 18,
              color: theme.iconTheme.color,
            ),
            const SizedBox(width: 8),
            Text(
              _getModeLabel(selectedMode),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: theme.iconTheme.color,
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<DisplayMode>>[
        PopupMenuItem<DisplayMode>(
          value: DisplayMode.compact,
          child: Row(
            children: [
              Icon(
                Icons.view_compact,
                size: 18,
                color: selectedMode == DisplayMode.compact
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color,
              ),
              const SizedBox(width: 12),
              Text(
                "Compact",
                style: TextStyle(
                  fontWeight: selectedMode == DisplayMode.compact
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: selectedMode == DisplayMode.compact
                      ? theme.colorScheme.primary
                      : null,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<DisplayMode>(
          value: DisplayMode.standard,
          child: Row(
            children: [
              Icon(
                Icons.view_agenda,
                size: 18,
                color: selectedMode == DisplayMode.standard
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color,
              ),
              const SizedBox(width: 12),
              Text(
                "Standard",
                style: TextStyle(
                  fontWeight: selectedMode == DisplayMode.standard
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: selectedMode == DisplayMode.standard
                      ? theme.colorScheme.primary
                      : null,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<DisplayMode>(
          value: DisplayMode.extended,
          child: Row(
            children: [
              Icon(
                Icons.view_stream,
                size: 18,
                color: selectedMode == DisplayMode.extended
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color,
              ),
              const SizedBox(width: 12),
              Text(
                "Extended",
                style: TextStyle(
                  fontWeight: selectedMode == DisplayMode.extended
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: selectedMode == DisplayMode.extended
                      ? theme.colorScheme.primary
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

