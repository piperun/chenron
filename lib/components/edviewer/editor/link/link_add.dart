import 'package:chenron/data_struct/item.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class LinkAdder extends StatefulWidget {
  final PlutoGridStateManager stateManager;
  final Function(FolderItem item) onAdd;
  const LinkAdder({super.key, required this.stateManager, required this.onAdd});

  @override
  State<LinkAdder> createState() => _LinkAdderState();
}

class _LinkAdderState extends State<LinkAdder> {
  final TextEditingController _linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: TextField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    labelText: "Link",
                    hintText: 'Insert URL',
                  ),
                  onChanged: (value) {
                    setState(() {});
                  })),
        ),
        TextButton.icon(
          onPressed: _linkController.text.isEmpty ? null : _handleAdd,
          label: const Text("Add"),
          style: TextButton.styleFrom(
            backgroundColor: _linkController.text.isEmpty
                ? Colors.grey[300]
                : Colors.blue[100],
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          icon: const Icon(Icons.add),
        ),
        const Spacer()
      ],
    );
  }

  void _handleAdd() {
    if (_linkController.text.isEmpty) return;
    widget.onAdd(
      FolderItem(
        type: FolderItemType.link,
        content: StringContent(_linkController.text),
      ),
    );
    widget.stateManager.appendRows([
      PlutoRow(cells: {
        "url": PlutoCell(value: _linkController.text),
        "comment": PlutoCell(value: ""),
        "createdAt": PlutoCell(value: ""),
      })
    ]);
    widget.stateManager.notifyListeners();
    //_linkController.clear();
  }
}
