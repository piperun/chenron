import "package:chenron/components/table/link_toolbar.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/models/item.dart";
import "package:flutter/material.dart";
import "package:trina_grid/trina_grid.dart";
import "package:collection/collection.dart";

//TODO: This will much later in v0.10+ be turned into a base for all editors and not just link.
// Effectively when we need document to actually exist it'll be added, for now as we only need links
// we can just use this... Still need to rename this to LinkEditor.
class ItemEditor extends StatefulWidget {
  final List<TrinaColumn> columns;
  final List<TrinaRow> rows;
  final Function(CUD<FolderItem>) onUpdate;

  const ItemEditor(
      {super.key,
      required this.columns,
      required this.rows,
      required this.onUpdate});

  @override
  State<ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends State<ItemEditor> {
  late TrinaGridStateManager stateManager;
  CUD<FolderItem> folderItems = CUD<FolderItem>();
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool checkedRows = false;
  @override
  void initState() {
    super.initState();
    stateManager = TrinaGridStateManager(
      columns: widget.columns,
      rows: widget.rows,
      gridFocusNode: FocusNode(),
      scroll: TrinaGridScrollController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinkToolbar(
            onDelete: checkedRows
                ? () {
                    final selectedRows = stateManager.checkedRows;
                    for (var row in selectedRows) {
                      int index = stateManager.refRows.indexOf(row);
                      if (index != -1) {
                        String url = row.cells["url"]!.value;
                        FolderItem? item = folderItems.create.firstWhereOrNull(
                          (item) => item.path == url,
                        );
                        if (item != null && item?.id != null) {
                          folderItems.create.remove(item);
                        } else if (item == null) {
                          folderItems.remove.add(row.cells["id"]!.value);
                        }
                      }
                    }
                    stateManager.removeRows(selectedRows);
                    setState(() {
                      checkedRows = false;
                      widget.onUpdate(folderItems);
                    });
                  }
                : null),
        SizedBox(
            height: 600,
            child: TrinaGrid(
              columns: widget.columns,
              rows: widget.rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              onRowChecked: (TrinaGridOnRowCheckedEvent event) => setState(() {
                checkedRows = stateManager.checkedRows.isNotEmpty;
              }),
              configuration: const TrinaGridConfiguration(
                columnSize: TrinaGridColumnSizeConfig(
                  autoSizeMode: TrinaAutoSizeMode.scale,
                ),
              ),
            ))
      ],
    );
  }

  void _handleAdd(FolderItem item) {
    setState(() {
      folderItems.create.add(item);
      widget.onUpdate(folderItems);
    });
  }
}
