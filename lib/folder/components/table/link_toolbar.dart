import 'package:chenron/folder/data_structs/folder_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LinkToolbar extends StatelessWidget {
  final Function onDelete;
  LinkToolbar({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final folderState = Provider.of<FolderProvider>(context);
    return Container(
        padding: const EdgeInsets.fromLTRB(5, 20, 0, 0),
        child: Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(
                Icons.highlight_remove,
                color: Colors.red,
                size: 30.0,
              ),
              label: const Text('Remove selected'),
              onPressed: () {
                onDelete();
              },
            ),
          ],
        ));
  }
}
