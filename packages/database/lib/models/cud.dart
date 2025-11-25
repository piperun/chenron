class CUD<T> {
  List<T> create = [];
  // Might need to be changed to a map if more complex logic is needed
  List<T> update = [];
  List<String> remove = [];

  CUD({
    List<T>? create,
    List<T>? update,
    List<String>? remove,
  })  : create = create ?? [],
        update = update ?? [],
        remove = remove ?? [];

  void addItem(T item) {
    create.add(item);
  }

  void updateItem(T item) {
    update.add(item);
  }

  void removeItem(String id) {
    remove.add(id);
  }

  bool get isNotEmpty {
    return create.isNotEmpty || update.isNotEmpty || remove.isNotEmpty;
  }
}


