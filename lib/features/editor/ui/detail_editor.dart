import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/utils/convert/folder_item_convert.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/models/item.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/folder/update.dart";
import "package:chenron/components/edviewer/editor/item_editor.dart";
import "package:signals/signals_flutter.dart";

class DetailEditor extends StatefulWidget {
  final FolderResult? currentData;

  const DetailEditor({
    super.key,
    required this.currentData,
  });

  @override
  State<DetailEditor> createState() => _DetailEditorState();
}

class _DetailEditorState extends State<DetailEditor> {
  bool _hasChanges = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<PlutoColumn> columns = [
    PlutoColumn(
      title: "URL",
      field: "url",
      type: PlutoColumnType.text(),
      enableRowChecked: true,
    ),
    PlutoColumn(
        title: "Added",
        field: "createdAt",
        type: PlutoColumnType.text(),
        enableEditingMode: false),
  ];
  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateChangesState);
    _descriptionController.addListener(_updateChangesState);
    _titleController.text = widget.currentData?.folder.title ?? "";
    _descriptionController.text = widget.currentData?.folder.description ?? "";
  }

  CUD<FolderItem> cudItems = CUD<FolderItem>();

  List<PlutoRow> _loadRows() {
    if (widget.currentData?.items != null) {
      final folderItems = widget.currentData!.items;
      return List.generate(folderItems.length, (index) {
        final link = folderItems[index];
        final String linkDate;
        if (link.createdAt != null) {
          linkDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(link.createdAt!);
        } else {
          linkDate = "";
        }

        return PlutoRow(
          cells: {
            "id": PlutoCell(value: link.id),
            "url": PlutoCell(value: convertItemToString(link.content)),
            "createdAt": PlutoCell(
              value: linkDate,
            )
          },
        );
      });
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Folder Details"), actions: [
        TextButton.icon(
          label: const Text("Save"),
          icon: const Icon(Icons.save),
          onPressed: _hasChanges
              ? () {
                  _saveChanges();
                }
              : null,
        ),
      ]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
                child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                  ),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                  ),
                ),
                ItemEditor(
                  columns: columns,
                  rows: _loadRows(),
                  onUpdate: (CUD<FolderItem> updatedItems) {
                    cudItems = updatedItems;
                    _updateChangesState();
                  },
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateChangesState);
    _descriptionController.removeListener(_updateChangesState);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateChangesState() {
    final hasChanges = cudItems.isNotEmpty ||
        _titleController.text != widget.currentData?.folder.title ||
        _descriptionController.text != widget.currentData?.folder.description;

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
      await database.appDatabase.updateFolder(widget.currentData!.folder.id,
          title: _titleController.text,
          description: _descriptionController.text,
          itemUpdates: cudItems);
      setState(() {
        _hasChanges = false;
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
}
