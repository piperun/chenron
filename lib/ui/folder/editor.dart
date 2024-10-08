import "package:chenron/components/edviewer/editor/detail_editor.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class FolderEditor extends StatelessWidget {
  final String folderId;

  const FolderEditor({
    super.key,
    required this.folderId,
  });

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);
    return StreamBuilder<FolderResult>(
      stream: database.watchFolder(folderId: folderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (!snapshot.hasData) {
          return const Text("No data available");
        }

        final folderData = snapshot.data!;

        return Column(
          children: [
            Expanded(
                child: DetailEditor(
              currentData: folderData,
            )),
          ],
        );
      },
    );
  }
}
