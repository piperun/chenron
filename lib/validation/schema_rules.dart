class LengthRule {
  final int min;
  final int? max;

  const LengthRule({this.min = 0, this.max});
}

class SchemaRules {
  static const title = LengthRule(min: 6, max: 30);
  static const description = LengthRule(min: 0, max: 1000);
  static const url = LengthRule(min: 11, max: 2048);
  static const tag = LengthRule(min: 3, max: 12);
}
