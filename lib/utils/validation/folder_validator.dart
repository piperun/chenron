import 'package:chenron/utils/validation/schema_rules.dart';
import 'package:validator_dart/validator_dart.dart';
import 'package:validator_dart/src/validators/is_length.dart';

class FolderValidator {
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title cannot be empty';
    }
    final valueLocaleCheck = Validator.isAlphanumeric(value, locale: 'en-US') ||
        Validator.isAlphanumeric(value, locale: 'sv-SE') ||
        Validator.isAlphanumeric(value, locale: 'ja-JP') ||
        Validator.isAlphanumeric(value, locale: 'ru-RU') ||
        Validator.isAlphanumeric(value, locale: 'uk-UA');

    if (!Validator.isLength(value,
        options: LengthOptions(
            min: SchemaRules.title.min, max: SchemaRules.title.max))) {
      return 'Title can only be between ${SchemaRules.title.min} and ${SchemaRules.title.max} characters';
    }

    if (!valueLocaleCheck) {
      return 'Title can only contain alphanumeric characters and spaces';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null &&
        !Validator.isLength(value,
            options: LengthOptions(min: 0, max: SchemaRules.description.max))) {
      return 'Description can be at most ${SchemaRules.description.max} characters long';
    }
    return null;
  }

  static String? validateTags(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    List<String> tags = value.split(',').map((tag) => tag.trim()).toList();
    if (!tags.every((tag) => Validator.isAlpha(tag))) {
      return 'Tags can only contain latin alphabetic characters';
    }
    return null;
  }
}
