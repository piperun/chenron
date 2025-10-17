import "package:flutter/material.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron/features/create/link/renderers/link_validation_dialog.dart";

class _StatusInfo {
  final IconData icon;
  final Color color;
  final String tooltip;
  
  _StatusInfo({
    required this.icon,
    required this.color,
    required this.tooltip,
  });
}

/// Renderer for displaying link validation status icons
class LinkStatusRenderer {
  static Widget build(LinkEntry entry, ThemeData theme, BuildContext context) {
    final statusInfo = _getStatusInfo(entry, theme);
    
    return InkWell(
      onTap: () => LinkValidationDialog.show(context, entry, theme),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Tooltip(
          message: statusInfo.tooltip,
          child: Icon(statusInfo.icon, size: 20, color: statusInfo.color),
        ),
      ),
    );
  }

  static _StatusInfo _getStatusInfo(LinkEntry entry, ThemeData theme) {
    return switch (entry.validationStatus) {
      LinkValidationStatus.pending => _StatusInfo(
        icon: Icons.schedule,
        color: theme.colorScheme.onSurfaceVariant,
        tooltip: "Pending validation",
      ),
      LinkValidationStatus.validating => _StatusInfo(
        icon: Icons.sync,
        color: theme.colorScheme.primary,
        tooltip: "Validating...",
      ),
      LinkValidationStatus.valid => _StatusInfo(
        icon: Icons.check_circle,
        color: Colors.green,
        tooltip: "Valid & reachable",
      ),
      LinkValidationStatus.invalid => _StatusInfo(
        icon: Icons.error,
        color: theme.colorScheme.error,
        tooltip: entry.validationMessage ?? "Invalid URL",
      ),
      LinkValidationStatus.unreachable => _StatusInfo(
        icon: Icons.warning,
        color: Colors.orange,
        tooltip: entry.validationMessage ?? "URL unreachable",
      ),
    };
  }
}
