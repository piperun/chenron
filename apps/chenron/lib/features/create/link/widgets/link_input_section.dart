import "package:chenron/features/create/link/widgets/link_inputs.dart";
import "package:chenron/features/create/link/widgets/link_mode_switcher.dart";
import "package:chenron/shared/section_card/section_card.dart";
import "package:flutter/material.dart";
import "package:chenron/features/create/link/notifiers/create_link_notifier.dart";
import "package:chenron/components/TextBase/editable_code_field.dart";
import "package:chenron/features/create/link/models/validation_result.dart";
import "package:chenron/features/create/link/services/bulk_validator_service.dart";

class LinkInputSection extends StatefulWidget {
  final InputMode mode;
  final ValueChanged<InputMode> onModeChanged;
  final ValueChanged<String> onAddSingle;
  final void Function(String, BulkValidationResult) onAddBulk;
  final String? singleInputError;
  final VoidCallback? onErrorDismissed;
  final String? keyPrefix;

  const LinkInputSection({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.onAddSingle,
    required this.onAddBulk,
    this.singleInputError,
    this.onErrorDismissed,
    this.keyPrefix,
  });

  @override
  State<LinkInputSection> createState() => _LinkInputSectionState();
}

class _LinkInputSectionState extends State<LinkInputSection> {
  final TextEditingController _singleController = TextEditingController();
  final GlobalKey<EditableCodeFieldState> _bulkFieldKey = GlobalKey();
  BulkValidationResult? _bulkValidationResult;

  @override
  void initState() {
    super.initState();
    _singleController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (widget.singleInputError != null) {
      widget.onErrorDismissed?.call();
    }
  }

  @override
  void dispose() {
    _singleController.removeListener(_onTextChanged);
    _singleController.dispose();
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
      final text = _bulkFieldKey.currentState?.text ?? "";
      if (text.trim().isNotEmpty) {
        // Validate the bulk input first
        final result = BulkValidatorService.validateBulkInput(text);

        // Update the UI with validation results
        setState(() {
          _bulkValidationResult = result;
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
    final currentText = _bulkFieldKey.currentState?.text ?? "";
    final lines = currentText.split("\n");
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

    // Update the field with only error lines
    final newText = remainingLines.join("\n");
    _bulkFieldKey.currentState?.text = newText;

    // Update validation to reflect the new state
    if (remainingLines
        .any((l) => l.trim().isNotEmpty && !l.trim().startsWith("#"))) {
      // Re-validate the remaining text
      final newResult = BulkValidatorService.validateBulkInput(newText);
      setState(() {
        _bulkValidationResult = newResult;
      });
    } else {
      // No lines left, clear validation
      setState(() {
        _bulkValidationResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardSection(
      title: const Text("Links"),
      sectionIcon: const Icon(Icons.bookmark),
      trailing: Text("Tip: Use '| tag1, tag2' or '#tag1 #tag2' for inline tags",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
      children: [
        ModeSwitcher(
          mode: widget.mode,
          onModeChanged: widget.onModeChanged,
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: widget.mode == InputMode.single
              ? SingleInput(
                  key: const ValueKey("single_input"),
                  keyPrefix: widget.keyPrefix,
                  controller: _singleController,
                  onAdd: _handleAdd,
                  errorText: widget.singleInputError,
                )
              : BulkInput(
                  fieldKey: _bulkFieldKey,
                  validationResult: _bulkValidationResult,
                  onAdd: _handleAdd,
                  onClear: () {
                    _bulkFieldKey.currentState?.clear();
                    setState(() {
                      _bulkValidationResult = null;
                    });
                  },
                  onDismissErrors: () => setState(() {
                    _bulkValidationResult = null;
                  }),
                ),
        ),
      ],
    );
  }
}

