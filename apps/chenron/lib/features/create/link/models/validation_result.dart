import "package:freezed_annotation/freezed_annotation.dart";

part "validation_result.freezed.dart";

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

/// Represents a specific validation error with its type and location
@freezed
abstract class ValidationError with _$ValidationError {
  const ValidationError._();

  const factory ValidationError({
    required ValidationErrorType type,
    required String message,
    int? startIndex,
    int? endIndex,
  }) = _ValidationError;

  @override
  String toString() => message;
}

/// Result of validating a single line of bulk input
@freezed
abstract class LineValidationResult with _$LineValidationResult {
  const LineValidationResult._();

  const factory LineValidationResult({
    required int lineNumber,
    required String rawLine,
    String? url,
    List<String>? tags,
    required bool isValid,
    @Default([]) List<ValidationError> errors,
  }) = _LineValidationResult;

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
