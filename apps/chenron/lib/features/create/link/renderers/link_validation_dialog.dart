import "package:flutter/material.dart";
import "package:chenron/features/create/link/models/link_entry.dart";

/// Dialog for displaying link validation status details
class LinkValidationDialog {
  static void show(BuildContext context, LinkEntry entry, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getStatusIcon(entry.validationStatus),
              color: _getStatusColor(entry.validationStatus, theme),
            ),
            const SizedBox(width: 12),
            const Text("URL Validation Status"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("URL:", style: theme.textTheme.labelSmall),
              const SizedBox(height: 4),
              SelectableText(
                entry.url,
                style: const TextStyle(fontFamily: "monospace"),
              ),
              const SizedBox(height: 16),
              _buildValidationChecks(entry, theme),
              if (entry.validationMessage != null) ...[
                const SizedBox(height: 16),
                Text("Details:", style: theme.textTheme.labelSmall),
                const SizedBox(height: 4),
                Text(
                  entry.validationMessage!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  static IconData _getStatusIcon(LinkValidationStatus status) {
    return switch (status) {
      LinkValidationStatus.pending => Icons.schedule,
      LinkValidationStatus.validating => Icons.sync,
      LinkValidationStatus.valid => Icons.check_circle,
      LinkValidationStatus.invalid => Icons.error,
      LinkValidationStatus.unreachable => Icons.warning,
    };
  }

  static Color _getStatusColor(LinkValidationStatus status, ThemeData theme) {
    return switch (status) {
      LinkValidationStatus.pending => theme.colorScheme.onSurfaceVariant,
      LinkValidationStatus.validating => theme.colorScheme.primary,
      LinkValidationStatus.valid => Colors.green,
      LinkValidationStatus.invalid => theme.colorScheme.error,
      LinkValidationStatus.unreachable => Colors.orange,
    };
  }

  static Widget _buildValidationChecks(LinkEntry entry, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(entry.validationStatus, theme).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Validation Checks",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem(
            "URL Format",
            entry.validationStatus != LinkValidationStatus.invalid,
            entry.validationStatus == LinkValidationStatus.invalid
                ? "Invalid format"
                : "Valid format",
            theme,
          ),
          const SizedBox(height: 8),
          _buildCheckItem(
            "DNS Resolution",
            entry.validationStatus == LinkValidationStatus.valid ||
                entry.validationStatus == LinkValidationStatus.validating,
            entry.validationStatus == LinkValidationStatus.valid
                ? "Domain resolved"
                : entry.validationStatus == LinkValidationStatus.validating
                    ? "Checking..."
                    : "Failed to resolve",
            theme,
          ),
          const SizedBox(height: 8),
          _buildCheckItem(
            "HTTP Response",
            entry.validationStatus == LinkValidationStatus.valid,
            entry.validationStatusCode != null
                ? "Status ${entry.validationStatusCode} ${_getStatusCodeDescription(entry.validationStatusCode!)}"
                : entry.validationStatus == LinkValidationStatus.validating
                    ? "Waiting..."
                    : "No response",
            theme,
          ),
        ],
      ),
    );
  }

  static Widget _buildCheckItem(
    String label,
    bool passed,
    String description,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: passed ? Colors.green : theme.colorScheme.error,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _getStatusCodeDescription(int code) {
    if (code >= 200 && code < 300) return "✓ Success";
    if (code >= 300 && code < 400) return "↪ Redirect";
    if (code >= 400 && code < 500) return "✗ Client error";
    if (code >= 500) return "✗ Server error";
    return "";
  }
}
