import "package:chenron/features/create/link/models/validation_result.dart";
import "package:chenron/features/create/link/services/url_parser_service.dart";
import "package:chenron/utils/validation/schema_rules.dart";
import "package:validator_dart/validator_dart.dart";

/// Service for validating bulk link input with detailed error reporting
class BulkValidatorService {
  /// Validates bulk input and returns detailed line-by-line results
  static BulkValidationResult validateBulkInput(String input) {
    final lines = input.split("\n");
    final results = <LineValidationResult>[];

    for (int i = 0; i < lines.length; i++) {
      final lineNumber = i + 1;
      final line = lines[i];

      // Skip empty lines and comments
      if (line.trim().isEmpty || line.trim().startsWith("#")) {
        continue;
      }

      results.add(_validateLine(lineNumber, line));
    }

    return BulkValidationResult(lines: results);
  }

  /// Validates a single line and returns detailed error information
  static LineValidationResult _validateLine(int lineNumber, String line) {
    final errors = <ValidationError>[];

    // Parse the line
    final parsed = UrlParserService.parseSingleLine(line);

    if (parsed == null) {
      errors.add(const ValidationError(
        type: ValidationErrorType.urlInvalidFormat,
        message: "Unable to parse line",
      ));

      return LineValidationResult(
        lineNumber: lineNumber,
        rawLine: line,
        isValid: false,
        errors: errors,
      );
    }

    // Validate URL
    final urlErrors = _validateUrl(parsed.url, line);
    errors.addAll(urlErrors);

    // Validate tags
    final tagErrors = _validateTags(parsed.tags, line);
    errors.addAll(tagErrors);

    return LineValidationResult(
      lineNumber: lineNumber,
      rawLine: line,
      url: parsed.url,
      tags: parsed.tags,
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validates a URL and returns detailed errors with positions
  static List<ValidationError> _validateUrl(String url, String originalLine) {
    final errors = <ValidationError>[];

    // Find URL position in the line
    final urlStart = originalLine.indexOf(url);
    final urlEnd = urlStart + url.length;

    if (url.isEmpty) {
      errors.add(ValidationError(
        type: ValidationErrorType.urlEmpty,
        message: "URL cannot be empty",
        startIndex: 0,
        endIndex: originalLine.length,
      ));
      return errors;
    }

    if (url.length < SchemaRules.url.min) {
      errors.add(ValidationError(
        type: ValidationErrorType.urlTooShort,
        message: "URL must be at least ${SchemaRules.url.min} characters",
        startIndex: urlStart,
        endIndex: urlEnd,
      ));
    }

    if (SchemaRules.url.max != null && url.length > SchemaRules.url.max!) {
      errors.add(ValidationError(
        type: ValidationErrorType.urlTooLong,
        message: "URL must not exceed ${SchemaRules.url.max} characters",
        startIndex: urlStart,
        endIndex: urlEnd,
      ));
    }

    if (!Validator.isURL(url)) {
      errors.add(ValidationError(
        type: ValidationErrorType.urlInvalidFormat,
        message: "URL format is invalid",
        startIndex: urlStart,
        endIndex: urlEnd,
      ));
    }

    return errors;
  }

  /// Validates tags and returns detailed errors with positions
  static List<ValidationError> _validateTags(
      List<String> tags, String originalLine) {
    final errors = <ValidationError>[];

    for (final tag in tags) {
      // Find tag position in the line (approximate)
      final tagStart = originalLine.indexOf(tag);
      final tagEnd = tagStart != -1 ? tagStart + tag.length : null;

      if (tag.isEmpty) {
        errors.add(ValidationError(
          type: ValidationErrorType.tagEmpty,
          message: "Tag cannot be empty",
          startIndex: tagStart != -1 ? tagStart : null,
          endIndex: tagEnd,
        ));
        continue;
      }

      if (tag.length < SchemaRules.tag.min) {
        errors.add(ValidationError(
          type: ValidationErrorType.tagTooShort,
          message:
              "Tag '$tag' must be at least ${SchemaRules.tag.min} characters",
          startIndex: tagStart != -1 ? tagStart : null,
          endIndex: tagEnd,
        ));
      }

      if (SchemaRules.tag.max != null && tag.length > SchemaRules.tag.max!) {
        errors.add(ValidationError(
          type: ValidationErrorType.tagTooLong,
          message: "Tag '$tag' must not exceed ${SchemaRules.tag.max} characters",
          startIndex: tagStart != -1 ? tagStart : null,
          endIndex: tagEnd,
        ));
      }

      if (!Validator.isAlpha(tag)) {
        errors.add(ValidationError(
          type: ValidationErrorType.tagInvalidCharacters,
          message: "Tag '$tag' can only contain alphabetic characters (a-z)",
          startIndex: tagStart != -1 ? tagStart : null,
          endIndex: tagEnd,
        ));
      }
    }

    return errors;
  }
}
