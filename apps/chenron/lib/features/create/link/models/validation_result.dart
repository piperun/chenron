/// Represents a specific validation error with its type and location
class ValidationError {
  final ValidationErrorType type;
  final String message;
  final int? startIndex;
  final int? endIndex;

  const ValidationError({
    required this.type,
    required this.message,
    this.startIndex,
    this.endIndex,
  });

  @override
  String toString() => message;
}

/// Types of validation errors that can occur
enum ValidationErrorType {
  urlEmpty,
  urlTooShort,
  urlTooLong,
  urlInvalidFormat,
  tagEmpty,
  tagTooShort,
  tagTooLong,
  tagInvalidCharacters,
}

/// Result of validating a single line of bulk input
class LineValidationResult {
  final int lineNumber;
  final String rawLine;
  final String? url;
  final List<String>? tags;
  final bool isValid;
  final List<ValidationError> errors;

  const LineValidationResult({
    required this.lineNumber,
    required this.rawLine,
    this.url,
    this.tags,
    required this.isValid,
    this.errors = const [],
  });

  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() {
    return 'Line $lineNumber: ${isValid ? "Valid" : "Invalid (${errors.length} errors)"}';
  }
}

/// Result of validating bulk input containing multiple lines
class BulkValidationResult {
  final List<LineValidationResult> lines;
  final int totalLines;
  final int validLines;
  final int invalidLines;

  BulkValidationResult({
    required this.lines,
  })  : totalLines = lines.length,
        validLines = lines.where((l) => l.isValid).length,
        invalidLines = lines.where((l) => !l.isValid).length;

  bool get hasErrors => invalidLines > 0;
  bool get hasValidLines => validLines > 0;

  List<LineValidationResult> get errorLines =>
      lines.where((l) => !l.isValid).toList();

  List<LineValidationResult> get validLinesData =>
      lines.where((l) => l.isValid).toList();

  @override
  String toString() {
    return "BulkValidation: $totalLines total, $validLines valid, $invalidLines invalid";
  }
}

