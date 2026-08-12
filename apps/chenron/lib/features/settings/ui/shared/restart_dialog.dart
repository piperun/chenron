import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:vibe/vibe.dart";

/// Blocking dialog for settings changes that only take effect after an
/// app restart. Its only action closes the app via [SystemNavigator.pop].
class RestartDialog extends StatelessWidget {
  final String title;
  final String message;

  const RestartDialog({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        const MinorButton(
          label: "Restart Now",
          onPressed: SystemNavigator.pop,
        ),
      ],
    );
  }
}
