import "package:chenron/components/table/link_toolbar.dart";
import "package:chenron/core/ui/base_switch.dart";
import "package:chenron/core/ui/folder_picker.dart";
import "package:chenron/core/ui/input_field.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/update.dart";
import "package:chenron/database/extensions/link/create.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/utils/validation/link_validator.dart";
import "package:flutter/material.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:chenron/components/tables/link_table.dart";
import "package:chenron/notifiers/link_table_notifier.dart";
import "package:chenron/models/item.dart";
import "package:signals/signals.dart";

class CreateLinkPage extends StatefulWidget {
  const CreateLinkPage({super.key});

  @override
  State<CreateLinkPage> createState() => _CreateLinkPageState();
}

class _CreateLinkPageState extends State<CreateLinkPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _linkController = TextEditingController();
  final DataGridNotifier _tableNotifier = DataGridNotifier();

  List<Folder> _selectedFolders = [];
  // Create a signal for links
  final links = signal<List<FolderItem>>([]);

  late List<PlutoColumn> _columns;
  late List<PlutoRow> _rows;

  // Add to state class:
  bool _isArchiveMode = false;

  @override
  void initState() {
    super.initState();
    _columns = [
      PlutoColumn(
        title: "URL",
        field: "url",
        type: PlutoColumnType.text(),
        enableRowChecked: true,
      ),
      PlutoColumn(
        title: "Comment",
        field: "comment",
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: "Tags",
        field: "tags",
        type: PlutoColumnType.text(),
      ),
    ];

    _rows = [];
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Links"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveLinks,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FolderPicker(
              onFoldersSelected: (selectedFolders) {
                setState(() => _selectedFolders = selectedFolders);
              },
            ),
            InputField(
                formKey: _formKey,
                controller: _linkController,
                labelText: "Link",
                buttonText: "Add",
                onPressed: _addLink,
                validator: LinkValidator.validateContent),
            BaseSwitch(
              value: _isArchiveMode,
              onChange: (value) => setState(() => _isArchiveMode = value),
              label: "Archive Link(s)",
            ),
            LinkToolbar(onDelete: _deleteSelected),
            Expanded(
              child: DataGrid(
                columns: _columns,
                rows: _rows,
                notifier: _tableNotifier,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addLink() {
    if (_formKey.currentState!.validate()) {
      final String newLink = _linkController.text.trim();

      if (!_isDuplicateLink(newLink)) {
        final Key idKey = UniqueKey();
        final newItem = FolderItem(
          key: idKey,
          type: FolderItemType.link,
          content: StringContent(value: newLink),
        );

        links.value = [...links.value, newItem];

        final newRow = PlutoRow(
          key: idKey,
          cells: {
            "url": PlutoCell(value: newLink),
            "comment": PlutoCell(value: ""),
            "tags": PlutoCell(value: []),
          },
        );

        _tableNotifier.appendRow(newRow);
        _linkController.clear();
      }
    }
  }

  bool _isDuplicateLink(String newLink) {
    return links.value.any((item) {
      if (item.content is StringContent) {
        return (item.content as StringContent).value == newLink;
      }
      return false;
    });
  }

  void _deleteSelected() {
    final selectedRows = _tableNotifier.stateManager?.checkedRows ?? [];

    links.value = links.value
        .where((item) => !selectedRows.any((row) => item.key == row.key))
        .toList();

    _tableNotifier.removeSelectedRows();
  }

  Future<void> _saveLinks() async {
    final db = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
    final appDb = db.appDatabase;

    final targetFolders = _selectedFolders.isEmpty
        ? ['default']
        : _selectedFolders.map((f) => f.id).toList();

    for (final folderId in targetFolders) {
      for (final link in links.value) {
        if (link.content is StringContent) {
          final linkId = await appDb.createLink(
            link: (link.content as StringContent).value,
            // TODO: When we implement tags for links.
          );

          await appDb.updateFolder(
            folderId,
            itemUpdates: CUD(
              create: [],
              update: [
                FolderItem(
                  type: FolderItemType.link,
                  itemId: linkId,
                  content: link.content,
                )
              ],
              remove: [],
            ),
          );
        }
      }
    }
    //FIXME: Flutter doesn't like having navigators in an async function.
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
