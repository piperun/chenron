import "package:chenron/components/TextBase/editable_code_field.dart";
import "package:chenron/features/create/link/models/validation_result.dart";
import "package:chenron/features/create/link/widgets/validation_error_panel.dart";
import "package:chenron/shared/labeled_text_field/labeled_text_field.dart";
import "package:flutter/material.dart";

class SingleInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  final String? errorText;

  const SingleInput({
    super.key,
    required this.controller,
    required this.onAdd,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey("single"),
      children: [
        Expanded(
          child: LabeledTextField(
              labelText: "URL",
              hintText: "https://example.com | tag1, tag2",
              controller: controller,
              onSubmitted: (_) => onAdd(),
              errorText: errorText,
              icon: const Icon(Icons.link)),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Add"),
        ),
      ],
    );
  }
}

class BulkInput extends StatelessWidget {
  final GlobalKey<EditableCodeFieldState> fieldKey;
  final BulkValidationResult? validationResult;
  final VoidCallback onAdd;
  final VoidCallback onClear;
  final VoidCallback? onDismissErrors;

  const BulkInput({
    super.key,
    required this.fieldKey,
    this.validationResult,
    required this.onAdd,
    required this.onClear,
    this.onDismissErrors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "URLs (one per line)",
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        EditableCodeField(
          key: fieldKey,
          validationResult: validationResult,
          maxLines: 8,
        ),
        // Error panel
        if (validationResult != null && validationResult!.hasErrors)
          ValidationErrorPanel(
            validationResult: validationResult!,
            onDismiss: onDismissErrors,
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: onClear,
                  child: const Text("Clear"),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: const Key("bulk_add_button"),
                  onPressed: onAdd,
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text("Parse & Add"),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
