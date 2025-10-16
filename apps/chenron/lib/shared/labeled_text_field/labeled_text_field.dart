import "package:flutter/material.dart";

class LabeledTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final Icon? icon;
  final TextEditingController controller;
  final String? errorText;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const LabeledTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.icon,
    this.errorText,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        prefixIcon: icon,
        errorText: errorText,
      ),
      maxLines: maxLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
