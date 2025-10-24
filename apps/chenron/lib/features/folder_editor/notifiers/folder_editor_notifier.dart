import "package:chenron/components/forms/folder_form.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/folder/update.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/models/db_result.dart";
import "package:chenron/database/database.dart";
import "package:chenron/locator.dart";
import "package:signals/signals.dart";
import "package:collection/collection.dart";

enum FolderEditorState {
  loading,
  loaded,
  error,
  saving,
}

/// Manages state for the folder editor feature using Signals with CUD pattern
class FolderEditorNotifier {
  final Signal<FolderEditorState> state = signal(FolderEditorState.loading);
  final Signal<String?> errorMessage = signal(null);
  final Signal<FolderResult?> folder = signal(null);

  // Items tracking with CUD pattern
  final Signal<List<FolderItem>> originalItems = signal([]);
  final Signal<CUD<FolderItem>> itemChanges = signal(CUD<FolderItem>(
    create: [],
    update: [],
    remove: [],
  ));

  final Signal<FolderFormData?> formData = signal(null);

  FolderResult? _originalFolder;

  // Computed signal for current items (original + changes)
  Computed<List<FolderItem>> get currentItems => computed(() {
        final original = originalItems.value;
        final changes = itemChanges.value;

        // Start with original items
        var items = List<FolderItem>.from(original);

        // Remove deleted items
        items.removeWhere((item) =>
            changes.remove.contains(item.id) ||
            changes.remove.any((removedId) => item.id == removedId));

        // Update modified items
        for (final updatedItem in changes.update) {
          final index = items.indexWhere((item) => item.id == updatedItem.id);
          if (index != -1) {
            items[index] = updatedItem;
          }
        }

        // Add new items
        items.addAll(changes.create);

        return items;
      });

  // Computed signal for filtered items (for search/display)
  Computed<List<FolderItem>> get displayItems => computed(() {
        return currentItems.value;
      });

  Computed<bool> get hasChanges => computed(() {
        final FolderResult? original = _originalFolder;
        final FolderFormData? current = formData.value;
        final CUD<FolderItem> changes = itemChanges.value;

        if (original == null || current == null) {
          return false;
        }

        final originalFolder = original.data;
        final originalTags = original.tags.map((t) => t.name).toSet();
        final currentTags = current.tags;

        // Check title change
        if (originalFolder.title != current.title) {
          return true;
        }

        // Check description change
        if (originalFolder.description != current.description) {
          return true;
        }

        // Check tags change
        if (!const SetEquality().equals(originalTags, currentTags)) {
          return true;
        }

        // Check parent folders change
        if (current.parentFolderIds.isNotEmpty) {
          return true;
        }

        // Check if there are any item changes
        if (changes.create.isNotEmpty ||
            changes.update.isNotEmpty ||
            changes.remove.isNotEmpty) {
          return true;
        }

        return false;
      });

  Future<void> loadFolder(String folderId) async {
    state.value = FolderEditorState.loading;
    errorMessage.value = null;

    try {
      final dbHandler =
          await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
      final folderResult = await dbHandler.appDatabase.getFolder(
        folderId: folderId,
        includeOptions: const IncludeOptions({
          AppDataInclude.items,
          AppDataInclude.tags,
        }),
      );

      if (folderResult == null) {
        state.value = FolderEditorState.error;
        errorMessage.value = "Folder not found";
        return;
      }

      _originalFolder = folderResult;
      folder.value = folderResult;
      originalItems.value = List.from(folderResult.items);

      // Reset item changes when loading
      itemChanges.value = CUD<FolderItem>(
        create: [],
        update: [],
        remove: [],
      );

      // Initialize form data from loaded folder
      formData.value = FolderFormData(
        title: folderResult.data.title,
        description: folderResult.data.description,
        parentFolderIds: [],
        tags: folderResult.tags.map((t) => t.name).toSet(),
        items: currentItems.value,
      );

      state.value = FolderEditorState.loaded;
    } catch (e) {
      state.value = FolderEditorState.error;
      errorMessage.value = e.toString();
    }
  }

  void updateFormData(FolderFormData data) {
    formData.value = data;
  }

  // Add a new item
  void addItem(FolderItem item) {
    final changes = itemChanges.value;
    itemChanges.value = CUD<FolderItem>(
      create: [...changes.create, item],
      update: changes.update,
      remove: changes.remove,
    );

    _updateFormDataItems();
  }

  // Update an existing item
  void updateItem(FolderItem item) {
    if (item.id == null) {
      // If it doesn't have an ID, it should be in create
      return;
    }

    final changes = itemChanges.value;

    // Check if this item is in the create list (newly added)
    final createIndex = changes.create.indexWhere((i) => i.id == item.id);
    if (createIndex != -1) {
      // Update the item in the create list
      final newCreate = List<FolderItem>.from(changes.create);
      newCreate[createIndex] = item;
      itemChanges.value = CUD<FolderItem>(
        create: newCreate,
        update: changes.update,
        remove: changes.remove,
      );
    } else {
      // It's an original item being updated
      final updateIndex = changes.update.indexWhere((i) => i.id == item.id);
      final newUpdate = List<FolderItem>.from(changes.update);

      if (updateIndex != -1) {
        newUpdate[updateIndex] = item;
      } else {
        newUpdate.add(item);
      }

      itemChanges.value = CUD<FolderItem>(
        create: changes.create,
        update: newUpdate,
        remove: changes.remove,
      );
    }

    _updateFormDataItems();
  }

  // Remove an item
  void removeItem(String itemId) {
    final changes = itemChanges.value;

    // Check if this item is in the create list
    final createIndex = changes.create.indexWhere((i) => i.id == itemId);
    if (createIndex != -1) {
      // Just remove it from create list
      final newCreate = List<FolderItem>.from(changes.create);
      newCreate.removeAt(createIndex);
      itemChanges.value = CUD<FolderItem>(
        create: newCreate,
        update: changes.update,
        remove: changes.remove,
      );
    } else {
      // Check if it's in update list
      final newUpdate = changes.update.where((i) => i.id != itemId).toList();

      // Add to remove list if it's an original item
      if (originalItems.value.any((i) => i.id == itemId)) {
        itemChanges.value = CUD<FolderItem>(
          create: changes.create,
          update: newUpdate,
          remove: [...changes.remove, itemId],
        );
      }
    }

    _updateFormDataItems();
  }

  // Remove multiple items at once
  void removeItems(Set<String> itemIds) {
    final changes = itemChanges.value;

    // Separate items into created vs original
    final createdIds = changes.create.map((i) => i.id).toSet();
    final idsToRemoveFromCreate = itemIds.intersection(createdIds);
    final idsToAddToRemove = itemIds.difference(createdIds);

    // Filter out removed items from create and update lists
    final newCreate = changes.create
        .where((i) => !idsToRemoveFromCreate.contains(i.id))
        .toList();
    final newUpdate =
        changes.update.where((i) => !itemIds.contains(i.id)).toList();

    // Add original items to remove list
    final originalIds = originalItems.value
        .where((i) => idsToAddToRemove.contains(i.id))
        .map((i) => i.id)
        .whereType<String>()
        .toList();

    itemChanges.value = CUD<FolderItem>(
      create: newCreate,
      update: newUpdate,
      remove: [...changes.remove, ...originalIds],
    );

    _updateFormDataItems();
  }

  // Bulk update items (for reordering, etc.)
  void setItems(List<FolderItem> newItems) {
    final original = originalItems.value;
    final originalIds = original.map((i) => i.id).toSet();
    final newIds = newItems.map((i) => i.id).toSet();

    // Items to create: in new but not in original
    final itemsToCreate = newItems
        .where((item) => item.id == null || !originalIds.contains(item.id))
        .toList();

    // Items to remove: in original but not in new
    final itemsToRemove =
        originalIds.difference(newIds).whereType<String>().toList();

    // Items to update: in both but might have changed
    final itemsToUpdate = newItems
        .where((item) => item.id != null && originalIds.contains(item.id))
        .where((item) {
      // Only include if actually changed
      final originalItem = original.firstWhere((o) => o.id == item.id);
      return originalItem != item; // You might need a better comparison here
    }).toList();

    itemChanges.value = CUD<FolderItem>(
      create: itemsToCreate,
      update: itemsToUpdate,
      remove: itemsToRemove,
    );

    _updateFormDataItems();
  }

  // Clear all changes
  void resetChanges() {
    itemChanges.value = CUD<FolderItem>(
      create: [],
      update: [],
      remove: [],
    );

    if (_originalFolder != null) {
      formData.value = FolderFormData(
        title: _originalFolder!.data.title,
        description: _originalFolder!.data.description,
        parentFolderIds: [],
        tags: _originalFolder!.tags.map((t) => t.name).toSet(),
        items: originalItems.value,
      );
    }
  }

  void _updateFormDataItems() {
    if (formData.value != null) {
      formData.value = formData.value!.copyWith(items: currentItems.value);
    }
  }

  Future<bool> saveChanges(String folderId) async {
    final current = formData.value;
    if (_originalFolder == null || current == null) {
      return false;
    }

    state.value = FolderEditorState.saving;

    try {
      final dbHandler =
          await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
      final appDb = dbHandler.appDatabase;

      final tagUpdates = _buildTagUpdates();
      final itemUpdates = itemChanges.value;

      // Update folder metadata and items
      await appDb.updateFolder(
        folderId,
        title: current.title,
        description: current.description,
        tagUpdates: tagUpdates,
        itemUpdates: itemUpdates,
      );

      // Handle parent folders
      if (current.parentFolderIds.isNotEmpty) {
        for (final parentFolderId in current.parentFolderIds) {
          await appDb.updateFolder(
            parentFolderId,
            itemUpdates: CUD(
              create: [],
              update: [
                FolderItem(
                  type: FolderItemType.folder,
                  itemId: folderId,
                  content: StringContent(value: current.title),
                )
              ],
              remove: [],
            ),
          );
        }
      }

      await loadFolder(folderId);

      return true;
    } catch (e) {
      state.value = FolderEditorState.error;
      errorMessage.value = "Failed to save changes: ${e.toString()}";
      return false;
    }
  }

  CUD<Metadata> _buildTagUpdates() {
    final current = formData.value;
    if (_originalFolder == null || current == null) {
      return CUD(create: [], update: [], remove: []);
    }

    final originalTags = _originalFolder!.tags;
    final currentTags = current.tags;

    // Tags to create: in current but not in original
    final tagsToCreate = currentTags
        .where((tag) => !originalTags.any((t) => t.name == tag))
        .map((tag) => Metadata(value: tag, type: MetadataTypeEnum.tag))
        .toList();

    // Tags to remove: in original but not in current
    final tagsToRemove = originalTags
        .where((tag) => !currentTags.contains(tag.name))
        .map((tag) => tag.id)
        .toList();

    return CUD(
      create: tagsToCreate,
      update: [],
      remove: tagsToRemove,
    );
  }

  void dispose() {
    state.dispose();
    errorMessage.dispose();
    folder.dispose();
    originalItems.dispose();
    itemChanges.dispose();
    formData.dispose();
  }
}
