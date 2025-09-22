import 'package:flutter/material.dart';

class DiscardDialog {
  static Future<bool> show(BuildContext context) async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Discard Unsaved Changes?"),
        content: const Text(
            "You have unsaved changes. Do you want to discard them and navigate away?"),
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
}