import 'package:chenron/components/edviewer/editor/item_editor.dart';
import 'package:chenron/data_struct/cud.dart';

import 'package:chenron/data_struct/folder.dart';
import 'package:chenron/data_struct/item.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/read.dart';
import 'package:chenron/database/extensions/folder/update.dart';
import 'package:chenron/providers/CUD_state.dart';
import 'package:chenron/providers/folder_info_state.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class DetailEditor extends StatefulWidget {
  final FolderLink? currentData;

  DetailEditor({
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
      title: 'URL',
      field: 'url',
      type: PlutoColumnType.text(),
      enableRowChecked: true,
    ),
    PlutoColumn(
      title: 'Comment',
      field: 'comment',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Tags',
      field: 'tags',
      type: PlutoColumnType.text(),
    ),
  ];
  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateChangesState);
    _descriptionController.addListener(_updateChangesState);
  }

  CUD<FolderItem> cudItems = CUD<FolderItem>();

  List<PlutoRow> _loadRows() {
    if (widget.currentData?.folderItems != null) {
      final folderItems = widget.currentData!.folderItems;
      return List.generate(folderItems.length, (index) {
        final link = folderItems[index];
        return PlutoRow(
          cells: {
            'id': PlutoCell(value: link.id),
            'url': PlutoCell(value: link.url),
            'comment': PlutoCell(value: ''),
            'tags': PlutoCell(value: ''),
          },
        );
      });
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = widget.currentData?.folderInfo.title ?? "";
    _descriptionController.text =
        widget.currentData?.folderInfo.description ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text('Folder Details'), actions: [
        IconButton(
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
                    labelText: 'Title',
                  ),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
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
    setState(() {
      _hasChanges = cudItems.isNotEmpty ||
          _titleController.text != widget.currentData?.folderInfo.title ||
          _descriptionController.text !=
              widget.currentData?.folderInfo.description;
    });
  }

  void _saveChanges() {
    final database = Provider.of<AppDatabase>(context, listen: false);
    try {
      database.updateFolder(widget.currentData!.folderInfo.id,
          title: _titleController.text,
          description: _descriptionController.text,
          itemUpdates: cudItems);
      setState(() {
        _hasChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save changes: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
