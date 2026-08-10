import "package:database/database.dart";

abstract interface class ItemViewportSource {
  int get length;

  FolderItem? itemAt(int index);

  Object? errorAt(int index);

  Future<void> retryAt(int index);
}

class MaterializedItemViewportSource implements ItemViewportSource {
  MaterializedItemViewportSource(List<FolderItem> items)
      : items = List<FolderItem>.unmodifiable(items);

  final List<FolderItem> items;

  @override
  int get length => items.length;

  @override
  FolderItem? itemAt(int index) =>
      index < 0 || index >= items.length ? null : items[index];

  @override
  Object? errorAt(int index) => null;

  @override
  Future<void> retryAt(int index) => Future<void>.value();
}

class PrefixedItemViewportSource implements ItemViewportSource {
  PrefixedItemViewportSource(
    List<FolderItem> prefix,
    this.delegate,
  ) : prefix = List<FolderItem>.unmodifiable(prefix);

  final List<FolderItem> prefix;
  final ItemViewportSource delegate;

  @override
  int get length => prefix.length + delegate.length;

  @override
  FolderItem? itemAt(int index) {
    if (index < 0 || index >= length) return null;
    if (index < prefix.length) return prefix[index];
    return delegate.itemAt(index - prefix.length);
  }

  @override
  Object? errorAt(int index) {
    if (index < 0 || index >= length) return null;
    if (index < prefix.length) return null;
    return delegate.errorAt(index - prefix.length);
  }

  @override
  Future<void> retryAt(int index) {
    if (index < 0 || index >= length) return Future<void>.value();
    if (index < prefix.length) return Future<void>.value();
    return delegate.retryAt(index - prefix.length);
  }
}

/// Adapts an indexed, dynamically-sized backing store without materializing it.
class DelegatingItemViewportSource implements ItemViewportSource {
  const DelegatingItemViewportSource({
    required int Function() length,
    required FolderItem? Function(int index) itemAt,
    required Object? Function(int index) errorAt,
    required Future<void> Function(int index) retryAt,
  })  : _length = length,
        _itemAt = itemAt,
        _errorAt = errorAt,
        _retryAt = retryAt;

  final int Function() _length;
  final FolderItem? Function(int index) _itemAt;
  final Object? Function(int index) _errorAt;
  final Future<void> Function(int index) _retryAt;

  @override
  int get length {
    final currentLength = _length();
    return currentLength < 0 ? 0 : currentLength;
  }

  @override
  FolderItem? itemAt(int index) =>
      index < 0 || index >= length ? null : _itemAt(index);

  @override
  Object? errorAt(int index) =>
      index < 0 || index >= length ? null : _errorAt(index);

  @override
  Future<void> retryAt(int index) =>
      index < 0 || index >= length ? Future<void>.value() : _retryAt(index);
}
