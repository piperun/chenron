import "package:flutter/material.dart";

class CredentialTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? tooltip;
  final bool isPassword;

  const CredentialTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.tooltip,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget textField = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
        ),
      ),
    );

    // Wrap with tooltip if provided
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        preferBelow: false,
        child: textField,
      );
    }

    return textField;
  }
}
