import "package:flutter/material.dart";
import "package:vibe/vibe.dart";

/// Shows a two-button confirmation dialog and returns whether the user
/// confirmed.
///
/// Resolves to `false` on barrier dismissal or Cancel, `true` only when the
/// confirm button is pressed. Callers can therefore use a plain
/// `if (await showConfirmDialog(...))` guard without null-checking.
///
/// Replaces the inline `showDialog<bool>` + `AlertDialog` +
/// `Cancel/Confirm` pattern that appeared in `tag_management_settings`,
/// `cache_settings`, `data_settings` (twice), and `configuration` discard
/// flow.
///
/// Set [destructive] to `true` for irreversible actions (delete, clear) —
/// the confirm button is rendered with the theme's error color.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = "Cancel",
  bool destructive = false,
  bool barrierDismissible = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          MinorButton(
            label: cancelLabel,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          MinorButton(
            label: confirmLabel,
            destructive: destructive,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
