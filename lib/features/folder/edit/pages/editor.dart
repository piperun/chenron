import "package:chenron/components/edviewer/editor/detail_editor.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/utils/logger.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class FolderEditor extends StatelessWidget {
  final String folderId;

  const FolderEditor({
    super.key,
    required this.folderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: EditorBody(
      folderId: folderId,
    ));
  }
}

class EditorBody extends StatelessWidget {
  final String folderId;
  const EditorBody({required this.folderId, super.key});
  Stream<FolderResult?> watchFolder() async* {
    try {
      final database = await locator
          .get<Signal<Future<AppDatabaseHandler>>>()
          .value
          .then((db) => db.appDatabase);
      yield* database.watchFolder(folderId: folderId);
    } catch (e) {
      loggerGlobal.severe("FolderViewerModel" "Error watching folders: $e", e);
      yield null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FolderResult?>(
      stream: watchFolder(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("No data available"));
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
