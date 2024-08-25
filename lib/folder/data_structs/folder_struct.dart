class Folder<T> {
  String title;
  String description;
  List<String> tags;
  List<T> data; // Data can be of any type (LinkData, DocumentData, Folder

  Folder({
    required this.title,
    required this.description,
    required this.tags,
    required this.data,
  });
  // Methods to update folder details
  void updateTitle(String newTitle) {
    title = newTitle;
  }

  void updateDescription(String newDescription) {
    description = newDescription;
  }

  void updateTags(List<String> newTags) {
    tags = newTags;
  }

  void updateData(List<T> newData) {
    data = newData;
  }
}
