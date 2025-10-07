import 'package:flutter/material.dart';
import 'package:vibe_core/src/spec/theme_spec.dart';
import 'package:vibe_core/src/validation/theme_validator.dart';

/// Validator that checks for basic Material Design theme compliance
final class MaterialThemeValidator extends ThemeValidator {
  final bool requireCardTheme;

  const MaterialThemeValidator({
    this.requireCardTheme = false,
  });

  @override
  ValidationResult validate(ThemeVariants variants) {
    final List<String> errors = <String>[];

    // Validate light theme
    _validateTheme(variants.light, 'light', errors);

    // Validate dark theme
    _validateTheme(variants.dark, 'dark', errors);

    return errors.isEmpty
        ? const ValidationSuccess()
        : ValidationFailure(errors);
  }

  void _validateTheme(
    ThemeData theme,
    String mode,
    List<String> errors,
  ) {
    // Check required overrides
    if (requireCardTheme && theme.cardTheme.color == null) {
      errors.add('$mode theme missing cardTheme.color override');
    }

    // Check that essential theme properties exist
    if (theme.colorScheme.primary == theme.colorScheme.secondary) {
      errors.add(
        '$mode theme has identical primary and secondary colors',
      );
    }
  }
}

/// No-op validator that always passes (useful for development/testing)
final class NoOpValidator extends ThemeValidator {
  const NoOpValidator();

  @override
  ValidationResult validate(ThemeVariants variants) {
    return const ValidationSuccess();
  }
}
