import "package:flutter/material.dart";
import "package:chenron/features/create/link/models/validation_result.dart";

/// Custom TextEditingController that highlights errors in the text
///
/// This controller overrides buildTextSpan to apply different text styles
/// to valid and invalid parts of the text based on validation results.
class ValidatingTextController extends TextEditingController {
  BulkValidationResult? _validationResult;
  TextStyle? _errorStyle;
  TextStyle? _normalStyle;

  ValidatingTextController({
    String? text,
    BulkValidationResult? validationResult,
    TextStyle? errorStyle,
    TextStyle? normalStyle,
  }) : super(text: text) {
    _validationResult = validationResult;
    _errorStyle = errorStyle;
    _normalStyle = normalStyle;
  }

  /// Updates the validation result and triggers a rebuild
  void updateValidation(BulkValidationResult? result) {
    _validationResult = result;
    notifyListeners();
  }

  /// Updates the error style used for highlighting invalid text
  void updateErrorStyle(TextStyle? style) {
    _errorStyle = style;
    notifyListeners();
  }

  /// Updates the normal style used for valid text
  void updateNormalStyle(TextStyle? style) {
    _normalStyle = style;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // If no validation result, use default rendering
    if (_validationResult == null || text.isEmpty) {
      return TextSpan(
        style: _normalStyle ?? style,
        text: text,
      );
    }

    final theme = Theme.of(context);
    final errorStyle = _errorStyle ??
        TextStyle(
          backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.3),
          color: theme.colorScheme.error,
          decoration: TextDecoration.underline,
          decorationColor: theme.colorScheme.error,
        );

    final normalStyle = _normalStyle ?? style;

    // Build a map of line numbers to their validation results
    final lineMap = <int, LineValidationResult>{};
    for (final lineResult in _validationResult!.lines) {
      lineMap[lineResult.lineNumber] = lineResult;
    }

    // Split text into lines and build TextSpan for each
    final lines = text.split("\n");
    final spans = <TextSpan>[];

    for (int i = 0; i < lines.length; i++) {
      final lineNumber = i + 1;
      final line = lines[i];
      final lineResult = lineMap[lineNumber];

      // Add newline from previous line (except for first line)
      if (i > 0) {
        spans.add(TextSpan(text: "\n", style: normalStyle));
      }

      // If this line has errors, highlight it
      if (lineResult != null && lineResult.hasErrors) {
        spans.add(TextSpan(
          text: line,
          style: errorStyle,
        ));
      } else {
        // Valid line or not in validation results
        spans.add(TextSpan(
          text: line,
          style: normalStyle,
        ));
      }
    }

    return TextSpan(style: normalStyle, children: spans);
  }
}
