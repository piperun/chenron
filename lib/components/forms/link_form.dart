import 'package:chenron/data_struct/item.dart';
import 'package:chenron/validation/link_validator.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:chenron/providers/CUD_state.dart';
import 'package:chenron/components/table/link_toolbar.dart';
import 'package:chenron/responsible_design/breakpoints.dart';
import 'package:chenron/components/forms/form/link_form_field.dart';

class LinkForm extends StatefulWidget {
  final GlobalKey<FormState> dataKey;
  const LinkForm({super.key, required this.dataKey});

  @override
  State<LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<LinkForm> {
  final TextEditingController _linkController = TextEditingController();
  late PlutoGridStateManager stateManager;

  List<PlutoColumn> columns = [
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
    stateManager = PlutoGridStateManager(
      columns: columns,
      rows: [],
      gridFocusNode: FocusNode(),
      scroll: PlutoGridScrollController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CUDProvider<FolderItem>>(
      builder: (context, folderItems, child) {
        List<PlutoRow> rows = folderItems.create
            .map((link) => PlutoRow(
                  cells: {
                    'url': PlutoCell(value: link.content),
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
                  linkProvider: folderItems,
                  validator: (_) {
                    if (folderItems.create.isEmpty &&
                        _linkController.text.isEmpty) {
                      return 'Please add at least one link';
                    }
                    return null;
                  },
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: Breakpoints.responsiveWidth(context),
                        child: TextFormField(
                          controller: _linkController,
                          decoration:
                              const InputDecoration(labelText: 'Enter Link'),
                          validator: LinkValidator.validateContent,
                          minLines: 1,
                          maxLines: Breakpoints.isMedium(context) ? 23 : 25,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.dataKey.currentState!.validate() != true) {
                            return;
                          }
                          folderItems.addItem(
                            FolderItem(
                              type: FolderItemType.link,
                              content: StringContent(_linkController.text),
                            ),
                          );
                          stateManager.appendRows([
                            PlutoRow(cells: {
                              "url": PlutoCell(value: _linkController.text),
                              "comment": PlutoCell(value: ""),
                              "tags": PlutoCell(value: [])
                            })
                          ]);
                          _linkController.clear();
                        },
                        child: const Text('Add Link'),
                      ),
                    ],
                  ),
                )),
            LinkToolbar(
              onDelete: () {
                final selectedRows = stateManager.checkedRows;
                //FIXME: More performant solution we will use at some point
                //Set.from(rows.map((e) => e));
                folderItems.create.removeWhere((item) => selectedRows.any(
                    (row) =>
                        stateManager.refRows.indexOf(row) ==
                        folderItems.create.indexOf(item)));
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
      },
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