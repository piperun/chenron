import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:chenron/folder/data_structs/link_data.dart';
import 'package:chenron/folder/data_structs/data_state.dart';
import 'package:chenron/folder/components/table/link_toolbar.dart';
import 'package:chenron/responsible_design/breakpoints.dart';
import 'package:chenron/folder/components/forms/form/link_form_field.dart';

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
    return Consumer<CUDProvider<LinkData>>(
      builder: (context, linkProvider, child) {
        List<PlutoRow> rows = linkProvider.create
            .map((link) => PlutoRow(
                  cells: {
                    'url': PlutoCell(value: link.url),
                    'comment': PlutoCell(value: link.comment),
                    'tags': PlutoCell(value: link.tags.join(', ')),
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
                  linkProvider: linkProvider,
                  validator: (_) {
                    if (linkProvider.create.isEmpty) {
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
                          minLines: 1,
                          maxLines: Breakpoints.isMedium(context) ? 23 : 25,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_linkController.text.isEmpty) return;
                          linkProvider.addItem(
                            LinkData(
                              url: _linkController.text,
                              comment: "",
                              tags: [],
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
                final selectedRows = stateManager.currentSelectingRows;
                for (var row in selectedRows) {
                  int index = stateManager.refRows.indexOf(row);
                  if (index != -1) {
                    linkProvider.removeItem(index);
                  }
                }
                stateManager.removeRows(selectedRows);
              },
            ),
            SizedBox(
              height: 500, // Adjust as needed
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
              height: 500, // Adjust as needed
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