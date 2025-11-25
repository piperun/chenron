import "package:flutter/material.dart";

class InfoField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Function(String)? onSaved;
  final Function(String)? onFieldSubmit;

  const InfoField({
    super.key,
    required this.labelText,
    required this.controller,
    this.validator,
    this.onSaved,
    this.onFieldSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      validator: validator,
      onSaved: onSaved != null ? (value) => onSaved!(value!) : null,
      onFieldSubmitted: onFieldSubmit,
    );
  }
}

