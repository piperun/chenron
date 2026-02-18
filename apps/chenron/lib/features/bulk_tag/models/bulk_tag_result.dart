/// The action the user chose for a given tag.
enum TagAction { none, add, remove }

/// Captures the user's intent from the bulk tag dialog.
class BulkTagResult {
  /// Tag names to add to all target items.
  final List<String> tagsToAdd;

  /// Tag names to remove from all target items.
  final List<String> tagsToRemove;

  const BulkTagResult({
    required this.tagsToAdd,
    required this.tagsToRemove,
  });

  bool get isEmpty => tagsToAdd.isEmpty && tagsToRemove.isEmpty;
}
