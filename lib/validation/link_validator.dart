import 'package:validator_dart/validator_dart.dart';

class LinkValidator {
  static String? validateContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Content cannot be empty';
    }
    if (!Validator.isURL(value)) {
      return 'Content must be a valid URL';
    }
    return null;
  }
}
