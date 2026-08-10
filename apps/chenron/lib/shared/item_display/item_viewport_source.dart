import "package:database/database.dart";

abstract interface class ItemViewportSource {
  int get length;

  FolderItem? itemAt(int index);

  Object? errorAt(int index);

  Future<void> retryAt(int index);
}

class MaterializedItemViewportSource implements ItemViewportSource {
  const MaterializedItemViewportSource(this.items);

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
  const PrefixedItemViewportSource(this.prefix, this.delegate);

  final List<FolderItem> prefix;
  final ItemViewportSource delegate;

  @override
  int get length => prefix.length + delegate.length;

  @override
  FolderItem? itemAt(int index) {
    if (index < 0) return null;
    if (index < prefix.length) return prefix[index];
    return delegate.itemAt(index - prefix.length);
  }

  @override
  Object? errorAt(int index) {
    if (index < prefix.length) return null;
    return delegate.errorAt(index - prefix.length);
  }

  @override
  Future<void> retryAt(int index) {
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
  int get length => _length();

  @override
  FolderItem? itemAt(int index) => _itemAt(index);

  @override
  Object? errorAt(int index) => _errorAt(index);

  @override
  Future<void> retryAt(int index) => _retryAt(index);
}
