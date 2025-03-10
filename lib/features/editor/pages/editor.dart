import "package:chenron/database/actions/handlers/read_handler.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/update.dart";
import "package:flutter/material.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/utils/logger.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/models/item.dart";

import "package:chenron/core/ui/editors/info_editor.dart";
import "package:chenron/core/ui/item_editor/item_editor.dart";
import "package:chenron/core/ui/item_editor/item_adder.dart";

class FolderEditor extends StatefulWidget {
  final String folderId;

  const FolderEditor({
    super.key,
    required this.folderId,
  });

  @override
  State<FolderEditor> createState() => _FolderEditorState();
}

class _FolderEditorState extends State<FolderEditor> {
  bool _hasChanges = false;
  CUD<FolderItem> cudItems = CUD<FolderItem>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Stream<Result<Folder>?> watchFolder() async* {
    final database =
        await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
    yield* database.appDatabase.watchFolder(folderId: widget.folderId);
  }

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateChangesState);
    _descriptionController.addListener(_updateChangesState);
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateChangesState);
    _descriptionController.removeListener(_updateChangesState);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Result<Folder>?>(
      stream: watchFolder(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final folderData = snapshot.data;
        if (folderData == null) {
          return const Scaffold(
            body: Center(child: Text("Folder not found")),
          );
        }

        _titleController.text = folderData.data.title;
        _descriptionController.text = folderData.data.description;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Folder Editor"),
            actions: [
              ItemAdder(
                onAddLink: _handleAddLink,
                onAddDocument: _handleAddDocument,
              ),
              TextButton.icon(
                label: const Text("Save"),
                icon: const Icon(Icons.save),
                onPressed: _hasChanges ? _saveChanges : null,
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      InfoEditor(
                        titleController: _titleController,
                        descriptionController: _descriptionController,
                      ),
                      ItemEditor(
                        //HACK: This is a hack to just make things work, will fix ItemEditort o take in a Set<Item> instead of a List<Item>
                        initialItems: folderData.items.toList(),
                        onUpdate: _handleItemEditorUpdate,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateChangesState() {
    if (!mounted) return;
    final hasChanges = cudItems.isNotEmpty ||
        _titleController.text != _titleController.text ||
        _descriptionController.text != _descriptionController.text;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  Future<void> _saveChanges() async {
    final database =
        await locator.get<Signal<Future<AppDatabaseHandler>>>().value;

    try {
      await database.appDatabase.updateFolder(
        widget.folderId,
        title: _titleController.text,
        description: _descriptionController.text,
        itemUpdates: cudItems,
      );
      setState(() {
        _hasChanges = false;
        cudItems = CUD<FolderItem>();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Changes saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save changes: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleAddLink(String url) {
    FolderItem newItem = FolderItem(
      content: StringContent(value: url),
      type: FolderItemType.link,
    );

    setState(() {
      cudItems.create.add(newItem);
      _updateChangesState();
    });
  }

  void _handleAddDocument(String documentContent) {
    FolderItem newItem = FolderItem(
      content: StringContent(value: documentContent),
      type: FolderItemType.document,
    );

    setState(() {
      cudItems.create.add(newItem);
      _updateChangesState();
    });
  }

  void _handleItemEditorUpdate(CUD<FolderItem> updatedItems) {
    cudItems.create.addAll(updatedItems.create);
    cudItems.update.addAll(updatedItems.update);
    cudItems.remove.addAll(updatedItems.remove);
    _updateChangesState();
  }
}
