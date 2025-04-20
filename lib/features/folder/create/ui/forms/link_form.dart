import "package:chenron/components/table/link_toolbar.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/utils/validation/link_validator.dart";
import "package:flutter/material.dart";
import "package:trina_grid/trina_grid.dart";
import "package:chenron/components/tables/link_table.dart";
import "package:chenron/notifiers/link_table_notifier.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/item.dart";
import "package:signals/signals.dart";

class LinkForm extends StatefulWidget {
  final GlobalKey<FormState> dataKey;

  const LinkForm({super.key, required this.dataKey});

  @override
  State<LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<LinkForm> {
  final GlobalKey<FormState> _linkFormKey = GlobalKey<FormState>();
  final TextEditingController _linkController = TextEditingController();
  final DataGridNotifier _tableNotifier = DataGridNotifier();

  final folderDraft = locator.get<Signal<FolderSignal>>();

  late List<TrinaColumn> _columns;
  late List<TrinaRow> _rows;

  @override
  void initState() {
    super.initState();
    _columns = [
      TrinaColumn(
        title: "URL",
        field: "url",
        type: TrinaColumnType.text(),
        enableRowChecked: true,
      ),
      TrinaColumn(
        title: "Comment",
        field: "comment",
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: "Tags",
        field: "tags",
        type: TrinaColumnType.text(),
      ),
    ];

    _rows = folderDraft.value.folder.items
        .map((link) => TrinaRow(
              key: link.key,
              cells: {
                "url": TrinaCell(value: (link.path as StringContent).value),
                "comment": TrinaCell(value: ""),
                "tags": TrinaCell(value: []),
              },
            ))
        .toList();
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: widget.dataKey,
          child: OverflowBar(
            children: [
              SizedBox(
                width: 500,
                child: Form(
                  key: _linkFormKey,
                  child: TextFormField(
                      controller: _linkController,
                      decoration:
                          const InputDecoration(labelText: "Enter Link"),
                      validator: LinkValidator.validateContent),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_linkFormKey.currentState!.validate()) {
                    final Key idKey = UniqueKey();

                    folderDraft.value.addItem(
                      FolderItem(
                        key: idKey,
                        type: FolderItemType.link,
                        content: StringContent(value: _linkController.text),
                      ),
                    );
                    final newRow = TrinaRow(
                      key: idKey,
                      cells: {
                        "url": TrinaCell(value: _linkController.text),
                        "comment": TrinaCell(value: ""),
                        "tags": TrinaCell(value: []),
                      },
                    );
                    _tableNotifier.appendRow(newRow, key: "url");
                    _linkController.clear();
                  }
                },
                child: const Text("Add Link"),
              ),
            ],
          ),
        ),
        LinkToolbar(
          onDelete: () {
            final selectedRows = _tableNotifier.stateManager?.checkedRows ?? [];
            folderDraft.value.folder.items.removeWhere(
                (item) => selectedRows.any((row) => item.key == row.key));
            _tableNotifier.removeSelectedRows();
          },
        ),
        SizedBox(
          height: 500,
          child: DataGrid(
            columns: _columns,
            rows: _rows,
            notifier: _tableNotifier,
          ),
        ),
      ],
    );
  }

  bool _isDuplicateLink(String newLink) {
    return folderDraft.value.folder.items.any((item) {
      if (item.path is StringContent) {
        return (item.path as StringContent).value == newLink;
      } else if (item.path is MapContent) {
        return (item.path as MapContent).value["url"] == newLink;
      }
      return false;
    });
  }

  void _addLink() {
    if (_linkFormKey.currentState!.validate()) {
      final String newLink = _linkController.text.trim();

      if (_isDuplicateLink(newLink)) {
      } else {
        final Key idKey = UniqueKey();
        final folderDraft = locator.get<Signal<FolderSignal>>().value;

        folderDraft.addItem(
          FolderItem(
            key: idKey,
            type: FolderItemType.link,
            content: StringContent(value: newLink),
          ),
        );

        final newRow = TrinaRow(
          key: idKey,
          cells: {
            "url": TrinaCell(value: newLink),
            "comment": TrinaCell(value: ""),
            "tags": TrinaCell(value: []),
          },
        );

        _tableNotifier.appendRow(newRow);
        _linkController.clear();
      }
    }
  }

  void _deleteSelected() {
    final folderDraft = locator.get<Signal<FolderSignal>>().value;
    final selectedRows = _tableNotifier.stateManager?.checkedRows ?? [];

    folderDraft.folder.items.removeWhere(
      (item) => selectedRows.any((row) => item.key == row.key),
    );

    _tableNotifier.removeSelectedRows();
  }
}
