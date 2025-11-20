import "package:flutter/material.dart";
import "package:chenron/features/create/link/models/validation_result.dart";

/// An editable code field with line numbers that stay perfectly aligned
///
/// Unlike TextField, this uses a custom text rendering approach similar to
/// flutter_syntax_view to ensure line numbers always align with text lines.
class EditableCodeField extends StatefulWidget {
  final String? initialText;
  final BulkValidationResult? validationResult;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;
  final int maxLines;

  const EditableCodeField({
    super.key,
    this.initialText,
    this.validationResult,
    this.onChanged,
    this.textStyle,
    this.maxLines = 8,
  });

  @override
  State<EditableCodeField> createState() => EditableCodeFieldState();
}

class EditableCodeFieldState extends State<EditableCodeField> {
  late TextEditingController _controller;
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController;
  late ScrollController _lineNumberScrollController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? "");
    _verticalScrollController = ScrollController();
    _horizontalScrollController = ScrollController();
    _lineNumberScrollController = ScrollController();
    _focusNode = FocusNode();

    _verticalScrollController.addListener(_syncScroll);
    _controller.addListener(() {
      widget.onChanged?.call(_controller.text);
      setState(() {}); // Rebuild to update line numbers
    });
  }

  @override
  void dispose() {
    _verticalScrollController.removeListener(_syncScroll);
    _controller.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    _lineNumberScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncScroll() {
    if (_lineNumberScrollController.hasClients) {
      _lineNumberScrollController.jumpTo(_verticalScrollController.offset);
    }
  }

  /// Get the current text
  String get text => _controller.text;

  /// Set the text programmatically
  set text(String value) {
    _controller.text = value;
  }

  /// Clear the text
  void clear() {
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = widget.textStyle ??
        TextStyle(
          fontFamily: "monospace",
          fontSize: 14,
          height: 1.4,
          color: theme.colorScheme.onSurface,
        );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox(
        height: widget.maxLines *
                (textStyle.fontSize ?? 14) *
                (textStyle.height ?? 1.4) +
            32,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line numbers
            _LineNumbers(
              text: _controller.text,
              validationResult: widget.validationResult,
              scrollController: _lineNumberScrollController,
              textStyle: textStyle,
            ),
            // Divider
            Container(
              width: 1,
              color: theme.colorScheme.outlineVariant,
            ),
            // Editable text area
            Expanded(
              child: _EditableTextArea(
                controller: _controller,
                focusNode: _focusNode,
                verticalScrollController: _verticalScrollController,
                horizontalScrollController: _horizontalScrollController,
                textStyle: textStyle,
                validationResult: widget.validationResult,
                maxLines: widget.maxLines,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Line numbers widget using the same approach as flutter_syntax_view
class _LineNumbers extends StatelessWidget {
  final String text;
  final BulkValidationResult? validationResult;
  final ScrollController scrollController;
  final TextStyle textStyle;

  const _LineNumbers({
    required this.text,
    required this.validationResult,
    required this.scrollController,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numLines = "\n".allMatches(text).length + 1;

    // Build error line set
    final errorLines = <int>{};
    if (validationResult != null) {
      for (final line in validationResult!.errorLines) {
        errorLines.add(line.lineNumber);
      }
    }

    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 1; i <= numLines; i++)
              Container(
                color: errorLines.contains(i)
                    ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
                    : theme.colorScheme.surfaceContainerHighest,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "$i",
                  style: textStyle.copyWith(
                    color: errorLines.contains(i)
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: errorLines.contains(i)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Editable text area using low-level EditableText for perfect control
class _EditableTextArea extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;
  final TextStyle textStyle;
  final BulkValidationResult? validationResult;
  final int maxLines;

  const _EditableTextArea({
    required this.controller,
    required this.focusNode,
    required this.verticalScrollController,
    required this.horizontalScrollController,
    required this.textStyle,
    required this.validationResult,
    required this.maxLines,
  });

  @override
  State<_EditableTextArea> createState() => _EditableTextAreaState();
}

class _EditableTextAreaState extends State<_EditableTextArea>
    implements TextSelectionGestureDetectorBuilderDelegate {
  late TextSelectionGestureDetectorBuilder _selectionGestureDetectorBuilder;
  final GlobalKey<EditableTextState> _editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder =
        TextSelectionGestureDetectorBuilder(delegate: this);
  }

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableTextKey;

  @override
  bool get forcePressEnabled => true;

  @override
  bool get selectionEnabled => true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      child: _selectionGestureDetectorBuilder.buildGestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // Error highlights layer (non-interactive)
            if (widget.validationResult != null &&
                widget.validationResult!.hasErrors)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ErrorHighlightPainter(
                      text: widget.controller.text,
                      textStyle: widget.textStyle,
                      validationResult: widget.validationResult!,
                      backgroundColor: theme.colorScheme.errorContainer
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            // Editable text layer (interactive)
            SingleChildScrollView(
              controller: widget.verticalScrollController,
              child: EditableText(
                key: _editableTextKey,
                controller: widget.controller,
                focusNode: widget.focusNode,
                style: widget.textStyle.copyWith(
                  backgroundColor: Colors.transparent,
                ),
                cursorColor: theme.colorScheme.primary,
                backgroundCursorColor: theme.colorScheme.surface,
                selectionColor: theme.colorScheme.primaryContainer,
                scrollController: null,
                maxLines: null,
                minLines: null,
                expands: false,
                scrollPadding: EdgeInsets.zero,
                selectionControls: materialTextSelectionControls,
                enableInteractiveSelection: true,
                showSelectionHandles: true,
                rendererIgnoresPointer: true, // Let gesture detector handle it
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter that draws error highlight backgrounds
class _ErrorHighlightPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final BulkValidationResult validationResult;
  final Color backgroundColor;

  _ErrorHighlightPainter({
    required this.text,
    required this.textStyle,
    required this.validationResult,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lines = text.split("\n");
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    double currentY = 0;

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final lineText = lines[lineIndex];
      final lineNumber = lineIndex + 1;

      // Calculate line height
      textPainter.text =
          TextSpan(text: lineText.isEmpty ? " " : lineText, style: textStyle);
      textPainter.layout();
      final lineHeight = textPainter.height;

      // Find validation result for this line
      final lineResult = validationResult.lines.firstWhere(
        (l) => l.lineNumber == lineNumber,
        orElse: () => LineValidationResult(
          lineNumber: lineNumber,
          rawLine: lineText,
          isValid: true,
        ),
      );

      if (!lineResult.isValid && lineResult.errors.isNotEmpty) {
        // Draw error highlights for this line
        for (final error in lineResult.errors) {
          if (error.startIndex != null && error.endIndex != null) {
            final start = error.startIndex!;
            final end = error.endIndex!;

            if (start >= lineText.length) continue;

            // Measure text before error
            final beforeText = lineText.substring(0, start);
            textPainter.text = TextSpan(text: beforeText, style: textStyle);
            textPainter.layout();
            final startX = textPainter.width;

            // Measure error text
            final errorText = end <= lineText.length
                ? lineText.substring(start, end)
                : lineText.substring(start);
            textPainter.text = TextSpan(text: errorText, style: textStyle);
            textPainter.layout();
            final errorWidth = textPainter.width;

            // Draw highlight rectangle
            final rect =
                Rect.fromLTWH(startX, currentY, errorWidth, lineHeight);
            canvas.drawRect(rect, Paint()..color = backgroundColor);
          }
        }
      }

      currentY += lineHeight;
    }
  }

  @override
  bool shouldRepaint(_ErrorHighlightPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.validationResult != validationResult;
  }
}
