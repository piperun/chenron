class LinkData {
  String url;
  String comment;
  List<String> tags;
  bool selected;

  LinkData(
      {required this.url,
      required this.comment,
      required this.tags,
      this.selected = false});

  // Method to create an iterator over the object's fields
  Iterator<MapEntry<String, dynamic>> fieldIterator() {
    return _toMap().entries.iterator;
  }

  // Helper method to convert fields to a map
  Map<String, dynamic> _toMap() {
    return {'url': url, 'comment': comment, 'tags': tags, 'selected': selected};
  }
}
