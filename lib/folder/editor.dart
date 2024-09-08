import 'package:chenron/components/edviewer/editor/detail_editor.dart';
import 'package:chenron/data_struct/folder.dart';
import 'package:chenron/data_struct/item.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/read.dart';
import 'package:chenron/database/extensions/folder/update.dart';
import 'package:chenron/providers/CUD_state.dart';
import 'package:chenron/providers/folder_info_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FolderEditor extends StatelessWidget {
  final String folderId;

  const FolderEditor({
    super.key,
    required this.folderId,
  });

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);
    final folderInfoProvider =
        Provider.of<FolderInfoProvider>(context, listen: false);
    final folderDataProvider =
        Provider.of<CUDProvider<FolderItem>>(context, listen: false);
    return StreamBuilder<FolderLink>(
      stream: database.watchTest(folderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Text('No data available');
        }

        final folderData = snapshot.data!;
        folderInfoProvider.title = folderData.folderInfo.title;
        folderInfoProvider.description = folderData.folderInfo.description;
        //folderInfoProvider.tags = folderData.folderInfo.tags;

        return Column(
          children: [
            Expanded(
                child: DetailEditor(
              currentData: folderData,
            )),

            // ElevatedButton(
            //onPressed: () => database.updateFolder(folderData),
            //child: Text('Save'),
            //),
          ],
        );
      },
    );
  }
}
