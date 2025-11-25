import "package:chenron/utils/validation/schema_rules.dart";
import "package:validator_dart/validator_dart.dart";
// ignore: implementation_imports
import "package:validator_dart/src/validators/is_length.dart";

class LinkValidator {
  static String? validateContent(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a URL.";
    }
    if (!Validator.isLength(value,
        options: LengthOptions(
            min: SchemaRules.url.min, max: SchemaRules.url.max))) {
      return "URL must be between ${SchemaRules.url.min} and ${SchemaRules.url.max} characters.";
    }
    if (!Validator.isURL(value)) {
      return "Please enter a valid URL (e.g. https://example.com).";
    }
    return null;
  }
}

