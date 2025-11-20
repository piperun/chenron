import "package:flutter/material.dart";
import "package:chenron/components/TextBase/validating_text_controller.dart";
import "package:chenron/features/create/link/models/validation_result.dart";

/// A text input field with line numbers and error highlighting
///
/// Similar to a code editor, this widget displays line numbers on the left
/// and highlights lines with validation errors in red.
class CodeInputField extends StatefulWidget {
  final ValidatingTextController controller;
  final BulkValidationResult? validationResult;
  final String? labelText;
  final String? hintText;
  final int maxLines;
  final TextStyle? textStyle;
  final VoidCallback? onChanged;

  const CodeInputField({
    super.key,
    required this.controller,
    this.validationResult,
    this.labelText,
    this.hintText,
    this.maxLines = 8,
    this.textStyle,
    this.onChanged,
  });

  @override
  State<CodeInputField> createState() => _CodeInputFieldState();
}

class _CodeInputFieldState extends State<CodeInputField> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _lineNumberScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Sync scroll controllers
    _scrollController.addListener(_syncScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_syncScroll);
    _scrollController.dispose();
    _lineNumberScrollController.dispose();
    super.dispose();
  }

  void _syncScroll() {
    if (_lineNumberScrollController.hasClients) {
      _lineNumberScrollController.jumpTo(_scrollController.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define text style - MUST be same for both TextField and line numbers
    final textStyle = widget.textStyle ??
        const TextStyle(
          fontFamily: "monospace",
          fontSize: 14,
          height: 1.4, // Explicit line height
        );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line numbers column
          _LineNumbers(
            controller: widget.controller,
            validationResult: widget.validationResult,
            scrollController: _lineNumberScrollController,
            textStyle: textStyle,
          ),
          // Divider
          Container(
            width: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: widget.controller,
              scrollController: _scrollController,
              decoration: const InputDecoration(
                isCollapsed: true, // Remove internal padding
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16, // Match gutter padding!
                ),
              ),
              maxLines: widget.maxLines,
              style: textStyle,
              onChanged: (_) => widget.onChanged?.call(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that displays line numbers with error highlighting
class _LineNumbers extends StatefulWidget {
  final ValidatingTextController controller;
  final BulkValidationResult? validationResult;
  final ScrollController scrollController;
  final TextStyle textStyle;

  const _LineNumbers({
    required this.controller,
    required this.validationResult,
    required this.scrollController,
    required this.textStyle,
  });

  @override
  State<_LineNumbers> createState() => _LineNumbersState();
}

class _LineNumbersState extends State<_LineNumbers> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        final lines = value.text.split("\n");
        final lineCount = lines.length;

        // Build a set of error line numbers for quick lookup
        final errorLines = <int>{};
        if (widget.validationResult != null) {
          for (final line in widget.validationResult!.errorLines) {
            errorLines.add(line.lineNumber);
          }
        }

        // Create table rows - one per line
        final tableRows = List.generate(
          lineCount,
          (index) {
            final lineNumber = index + 1;
            final hasError = errorLines.contains(lineNumber);

            return TableRow(
              decoration: BoxDecoration(
                color: hasError
                    ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
                    : theme.colorScheme.surfaceContainerHighest,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    lineNumber.toString(),
                    style: widget.textStyle.copyWith(
                      color: hasError
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          hasError ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            );
          },
        );

        return Container(
          width: 48,
          padding: const EdgeInsets.symmetric(vertical: 16), // Match TextField!
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const NeverScrollableScrollPhysics(),
            child: Table(
              // Use Table widget like flutter-code-editor
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: tableRows,
            ),
          ),
        );
      },
    );
  }
}
