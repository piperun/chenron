import "package:flutter/material.dart";
import "package:chenron/features/create/link/notifiers/create_link_notifier.dart";
import "package:chenron/components/TextBase/code_input_field.dart";
import "package:chenron/components/TextBase/validating_text_controller.dart";
import "package:chenron/features/create/link/models/validation_result.dart";
import "package:chenron/features/create/link/services/bulk_validator_service.dart";
import "package:chenron/features/create/link/widgets/validation_error_panel.dart";

class LinkInputSection extends StatefulWidget {
  final InputMode mode;
  final ValueChanged<InputMode> onModeChanged;
  final ValueChanged<String> onAddSingle;
  final void Function(String, BulkValidationResult) onAddBulk;

  const LinkInputSection({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.onAddSingle,
    required this.onAddBulk,
  });

  @override
  State<LinkInputSection> createState() => _LinkInputSectionState();
}

class _LinkInputSectionState extends State<LinkInputSection> {
  final TextEditingController _singleController = TextEditingController();
  late final ValidatingTextController _bulkController;
  BulkValidationResult? _bulkValidationResult;
  String? _singleInputError;

  @override
  void initState() {
    super.initState();
    _bulkController = ValidatingTextController();
  }

  @override
  void dispose() {
    _singleController.dispose();
    _bulkController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    if (widget.mode == InputMode.single) {
      final text = _singleController.text.trim();
      if (text.isNotEmpty) {
        widget.onAddSingle(text);
        _singleController.clear();
      }
    } else {
      final text = _bulkController.text;
      if (text.trim().isNotEmpty) {
        // Validate the bulk input first
        final result = BulkValidatorService.validateBulkInput(text);
        
        // Update the UI with validation results
        setState(() {
          _bulkValidationResult = result;
          _bulkController.updateValidation(result);
        });
        
        // Pass to parent for processing
        widget.onAddBulk(text, result);
        
        // After processing, remove valid lines and keep only errors
        if (result.hasValidLines) {
          _removeValidLinesFromInput(result);
        }
      }
    }
  }
  
  /// Removes valid lines from the input, leaving only error lines
  void _removeValidLinesFromInput(BulkValidationResult result) {
    final lines = _bulkController.text.split("\n");
    final errorLineNumbers = result.errorLines.map((e) => e.lineNumber).toSet();
    final remainingLines = <String>[];
    
    for (int i = 0; i < lines.length; i++) {
      final lineNumber = i + 1;
      final line = lines[i];
      
      // Keep the line if:
      // 1. It has errors (in errorLineNumbers)
      // 2. It's empty or a comment (not processed by validator)
      if (errorLineNumbers.contains(lineNumber) ||
          line.trim().isEmpty ||
          line.trim().startsWith("#")) {
        remainingLines.add(line);
      }
    }
    
    // Update the controller with only error lines
    final newText = remainingLines.join("\n");
    _bulkController.text = newText;
    
    // Update validation to reflect the new state
    if (remainingLines.any((l) => l.trim().isNotEmpty && !l.trim().startsWith("#"))) {
      // Re-validate the remaining text
      final newResult = BulkValidatorService.validateBulkInput(newText);
      setState(() {
        _bulkValidationResult = newResult;
        _bulkController.updateValidation(newResult);
      });
    } else {
      // No lines left, clear validation
      setState(() {
        _bulkValidationResult = null;
        _bulkController.updateValidation(null);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ModeSwitcher(
                  mode: widget.mode,
                  onModeChanged: widget.onModeChanged,
                ),
                if (widget.mode == InputMode.bulk)
                  Text(
                    "Tip: Use '| tag1, tag2' or '#tag1 #tag2' for inline tags",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.mode == InputMode.single
                  ? _SingleInput(
                      controller: _singleController,
                      onAdd: _handleAdd,
                      errorText: _singleInputError,
                    )
                  : _BulkInput(
                      controller: _bulkController,
                      validationResult: _bulkValidationResult,
                      onAdd: _handleAdd,
                      onClear: () {
                        _bulkController.clear();
                        setState(() {
                          _bulkValidationResult = null;
                          _bulkController.updateValidation(null);
                        });
                      },
                      onDismissErrors: () => setState(() {
                        _bulkValidationResult = null;
                        _bulkController.updateValidation(null);
                      }),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  final InputMode mode;
  final ValueChanged<InputMode> onModeChanged;

  const _ModeSwitcher({
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeButton(
            label: "Single",
            isActive: mode == InputMode.single,
            onTap: () => onModeChanged(InputMode.single),
          ),
          _ModeButton(
            label: "Bulk",
            isActive: mode == InputMode.bulk,
            onTap: () => onModeChanged(InputMode.bulk),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isActive
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SingleInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  final String? errorText;

  const _SingleInput({
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
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "URL",
              hintText: "https://example.com | tag1, tag2",
              border: const OutlineInputBorder(),
              errorText: errorText,
              errorMaxLines: 3,
            ),
            onSubmitted: (_) => onAdd(),
          ),
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

class _BulkInput extends StatelessWidget {
  final ValidatingTextController controller;
  final BulkValidationResult? validationResult;
  final VoidCallback onAdd;
  final VoidCallback onClear;
  final VoidCallback? onDismissErrors;

  const _BulkInput({
    required this.controller,
    this.validationResult,
    required this.onAdd,
    required this.onClear,
    this.onDismissErrors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("bulk"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label above the input
        Text(
          "URLs (one per line)",
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        CodeInputField(
          controller: controller,
          validationResult: validationResult,
          hintText: "https://example.com | tag1, tag2\nhttps://another.com #tag1 #tag2\n# Lines starting with # are comments",
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final lines = value.text.split("\n").where((l) => l.trim().isNotEmpty).length;
                return Text(
                  "$lines line${lines != 1 ? 's' : ''}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                );
              },
            ),
            Row(
              children: [
                TextButton(
                  onPressed: onClear,
                  child: const Text("Clear"),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
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
