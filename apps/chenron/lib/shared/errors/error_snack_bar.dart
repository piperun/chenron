import "package:flutter/material.dart";
import "package:chenron/shared/errors/user_error_message.dart";

/// Shows a themed error SnackBar with a user-friendly message.
///
/// Callers must check `mounted` before invoking this.
void showErrorSnackBar(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(userErrorMessage(error)),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 4),
    ),
  );
}
