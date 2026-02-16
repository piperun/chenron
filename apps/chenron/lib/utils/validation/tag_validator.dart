import "package:chenron/utils/validation/schema_rules.dart";
import "package:validator_dart/validator_dart.dart";
// ignore: implementation_imports
import "package:validator_dart/src/validators/is_length.dart";

class TagValidator {
  /// Validates a single tag
  /// 
  /// Rules:
  /// - Must be between min and max length (from SchemaRules.tag)
  /// - Must contain only alphanumeric characters (a-z, 0-9)
  /// - Must not be purely numeric (at least one letter required)
  static String? validateTag(String? value) {
    if (value == null || value.isEmpty) {
      return "Tag cannot be empty";
    }

    if (!Validator.isLength(value,
        options: LengthOptions(
            min: SchemaRules.tag.min,
            max: SchemaRules.tag.max))) {
      return "Tag must be ${SchemaRules.tag.min}-${SchemaRules.tag.max} characters";
    }

    if (Validator.isNumeric(value)) {
      return "Tag must contain at least one letter";
    }

    if (!Validator.isAlphanumeric(value)) {
      return "Tag can only contain letters and numbers (a-z, 0-9)";
    }

    return null;
  }
  
  /// Validates a list of tags
  /// 
  /// Returns the first validation error encountered, or null if all valid
  static String? validateTags(List<String> tags) {
    for (final tag in tags) {
      final error = validateTag(tag);
      if (error != null) {
        return "$error: '$tag'";
      }
    }
    return null;
  }
  
  /// Validates a comma-separated string of tags
  /// 
  /// Useful for form inputs where tags are entered as "tag1, tag2, tag3"
  static String? validateTagString(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Empty is valid (no tags)
    }
    
    final tags = value.split(",").map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
    return validateTags(tags);
  }
}

