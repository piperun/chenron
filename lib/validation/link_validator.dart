import 'package:chenron/validation/schema_rules.dart';
import 'package:validator_dart/validator_dart.dart';
import 'package:validator_dart/src/validators/is_length.dart';

class LinkValidator {
  static String? validateContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Content cannot be empty';
    }
    if (!Validator.isLength(value,
        options: LengthOptions(
            min: SchemaRules.url.min, max: SchemaRules.url.max))) {
      return 'Content must be at least 10 characters long';
    }
    if (!Validator.isURL(value)) {
      return 'Content must be a valid URL';
    }
    return null;
  }
}
