import 'package:vibe_core/src/spec/theme_spec.dart';

/// Validation result for theme compliance checks
sealed class ValidationResult {
  const ValidationResult();
}

/// Theme passed all validation checks
class ValidationSuccess extends ValidationResult {
  const ValidationSuccess();

  @override
  String toString() => 'ValidationSuccess()';
}

/// Theme failed one or more validation checks
class ValidationFailure extends ValidationResult {
  final List<String> errors;

  const ValidationFailure(this.errors);

  @override
  String toString() => 'ValidationFailure(errors: $errors)';
}

/// Exception thrown when theme validation fails
class ThemeValidationException implements Exception {
  final String message;
  final List<String> errors;

  ThemeValidationException(this.message, {this.errors = const <String>[]});

  @override
  String toString() {
    if (errors.isEmpty) {
      return 'ThemeValidationException: $message';
    }
    return 'ThemeValidationException: $message\n  - ${errors.join('\n  - ')}';
  }
}

/// Contract for validating theme implementations
abstract base class ThemeValidator {
  const ThemeValidator();

  /// Validate that a theme meets all requirements
  ValidationResult validate(ThemeVariants variants);

  /// Check specific required widget theme overrides
  /// Throws ThemeValidationException if validation fails
  void assertRequiredOverrides(ThemeVariants variants) {
    final ValidationResult result = validate(variants);
    if (result is ValidationFailure) {
      throw ThemeValidationException(
        'Theme validation failed',
        errors: result.errors,
      );
    }
  }
}
