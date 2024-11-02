import "package:chenron/components/table/link_toolbar.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/utils/validation/link_validator.dart";
import "package:flutter/material.dart";
import "package:pluto_grid/pluto_grid.dart";
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
  final DataTableNotifier _tableNotifier = DataTableNotifier();

  final folderDraft = locator.get<Signal<FolderDraft>>();

  late List<PlutoColumn> _columns;
  late List<PlutoRow> _rows;

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

    _rows = folderDraft.value.folder.items
        .map((link) => PlutoRow(
              key: link.key,
              cells: {
                "url": PlutoCell(value: (link.content as StringContent).value),
                "comment": PlutoCell(value: ""),
                "tags": PlutoCell(value: []),
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
                    final newRow = PlutoRow(
                      key: idKey,
                      cells: {
                        "url": PlutoCell(value: _linkController.text),
                        "comment": PlutoCell(value: ""),
                        "tags": PlutoCell(value: []),
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
          child: FolderDataTable(
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
      if (item.content is StringContent) {
        return (item.content as StringContent).value == newLink;
      } else if (item.content is MapContent) {
        return (item.content as MapContent).value["url"] == newLink;
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
        final folderDraft = locator.get<Signal<FolderDraft>>().value;

        folderDraft.addItem(
          FolderItem(
            key: idKey,
            type: FolderItemType.link,
            content: StringContent(value: newLink),
          ),
        );

        final newRow = PlutoRow(
          key: idKey,
          cells: {
            'url': PlutoCell(value: newLink),
            'comment': PlutoCell(value: ''),
            'tags': PlutoCell(value: []),
          },
        );

        _tableNotifier.appendRow(newRow);
        _linkController.clear();
      }
    }
  }

  void _deleteSelected() {
    final folderDraft = locator.get<Signal<FolderDraft>>().value;
    final selectedRows = _tableNotifier.stateManager?.checkedRows ?? [];

    folderDraft.folder.items.removeWhere(
      (item) => selectedRows.any((row) => item.key == row.key),
    );

    _tableNotifier.removeSelectedRows();
  }
}
