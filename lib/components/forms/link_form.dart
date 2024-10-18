import "package:chenron/locator.dart";
import "package:chenron/models/item.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/utils/validation/link_validator.dart";
import "package:flutter/material.dart";
import "package:pluto_grid/pluto_grid.dart";
import "package:chenron/components/table/link_toolbar.dart";
import "package:chenron/responsible_design/breakpoints.dart";
import "package:chenron/components/forms/form/link_form_field.dart";

class LinkForm extends StatefulWidget {
  final GlobalKey<FormState> dataKey;
  const LinkForm({super.key, required this.dataKey});

  @override
  State<LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<LinkForm> {
  final GlobalKey<FormState> _linkFormKey = GlobalKey<FormState>();
  final TextEditingController _linkController = TextEditingController();
  late PlutoGridStateManager stateManager;

  List<PlutoColumn> columns = [
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
  @override
  void initState() {
    super.initState();
    stateManager = PlutoGridStateManager(
      columns: columns,
      rows: [],
      gridFocusNode: FocusNode(),
      scroll: PlutoGridScrollController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final folderLinkProvider = locator.get<FolderDraft>();
    List<PlutoRow> rows = folderLinkProvider.folder.items
        .map((link) => PlutoRow(
              cells: {
                "url": PlutoCell(value: link.content),
              },
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: widget.dataKey,
          child: LinkFormField(
            linkProvider: folderLinkProvider.folder.items,
            validator: (_) {
              if (folderLinkProvider.folder.items.isEmpty) {
                return "Please add at least one link";
              }
              return null;
            },
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: Breakpoints.responsiveWidth(context),
                  child: Form(
                    key: _linkFormKey,
                    child: TextFormField(
                      controller: _linkController,
                      decoration:
                          const InputDecoration(labelText: "Enter Link"),
                      validator: LinkValidator.validateContent,
                      minLines: 1,
                      maxLines: Breakpoints.isMedium(context) ? 23 : 25,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_linkFormKey.currentState!.validate()) {
                      final Key idKey = UniqueKey();
                      folderLinkProvider.addItem(
                        FolderItem(
                          key: idKey,
                          type: FolderItemType.link,
                          content: StringContent(value: _linkController.text),
                        ),
                      );
                      stateManager.appendRows([
                        PlutoRow(
                          key: idKey,
                          cells: {
                            "url": PlutoCell(value: _linkController.text),
                            "comment": PlutoCell(value: ""),
                            "tags": PlutoCell(value: [])
                          },
                        )
                      ]);
                      _linkController.clear();
                    }
                  },
                  child: const Text("Add Link"),
                ),
              ],
            ),
          ),
        ),
        LinkToolbar(
          onDelete: () {
            final selectedRows = stateManager.checkedRows;
            folderLinkProvider.folder.items
                .removeWhere((item) => selectedRows.any((row) {
                      return item.key == row.key;
                    }));
            stateManager.removeRows(selectedRows);
          },
        ),
        SizedBox(
          height: 500,
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;
            },
            configuration: const PlutoGridConfiguration(
              columnSize: PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.scale,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
/*
            SizedBox(
              height: 500,
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
                configuration: const PlutoGridConfiguration(
                  columnSize: PlutoGridColumnSizeConfig(
                    autoSizeMode: PlutoAutoSizeMode.scale,
                  ),
                ),
              ),
            ),*/
