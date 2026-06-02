/// The action the user chose for a given tag.
enum TagAction { none, add, remove }

/// Captures the user's intent from the bulk tag dialog.
class BulkTagResult {
  /// Tag names to add to all target items.
  final List<String> tagsToAdd;

  /// Tag names to remove from all target items.
  final List<String> tagsToRemove;

  /// Tag name → new color (ARGB int, or null to clear), for tags whose
  /// color the user changed. Applied globally to the tag, committed only
  /// when the dialog is confirmed — picking a color then cancelling
  /// leaves the stored color untouched.
  final Map<String, int?> colorChanges;

  const BulkTagResult({
    required this.tagsToAdd,
    required this.tagsToRemove,
    this.colorChanges = const {},
  });

  bool get isEmpty =>
      tagsToAdd.isEmpty && tagsToRemove.isEmpty && colorChanges.isEmpty;
}
