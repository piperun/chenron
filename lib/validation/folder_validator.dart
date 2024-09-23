import 'package:validator_dart/validator_dart.dart';
import 'package:validator_dart/src/validators/is_length.dart';

class FolderValidator {
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title cannot be empty';
    }

    final valueLocaleCheck = Validator.isAlphanumeric(value, locale: "en-US") ||
        Validator.isAlphanumeric(value, locale: "sv-SE") ||
        Validator.isAlphanumeric(value, locale: "ja-JP") ||
        Validator.isAlphanumeric(value, locale: "ru-RU") ||
        Validator.isAlphanumeric(value, locale: "uk-UA");

    if (!Validator.isLength(value, options: LengthOptions(min: 3, max: 50))) {
      return 'Title must be at least 3 characters long';
    }
    if (!valueLocaleCheck) {
      return 'Title can only contain alphanumeric characters and spaces';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null &&
        !Validator.isLength(value, options: LengthOptions(min: 0, max: 500))) {
      return 'Description must be between 10 and 500 characters';
    }
    return null;
  }

  static String? validateTags(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    List<String> tags = value.split(',').map((tag) => tag.trim()).toList();
    if (!tags.every((tag) => Validator.isAlphanumeric(tag))) {
      return 'Tags must be alphanumeric';
    }
    return null;
  }
}
