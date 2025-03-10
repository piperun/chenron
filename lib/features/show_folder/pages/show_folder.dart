import "package:chenron/core/ui/search/search_button.dart";
import "package:chenron/database/actions/handlers/read_handler.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/features/show_folder/widgets/folder_detail_info.dart";
import "package:chenron/features/show_folder/widgets/folder_detail_items.dart";
import "package:chenron/locator.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class ShowFolder extends StatelessWidget {
  final String folderId;

  const ShowFolder({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    final Future<Result<Folder>> folderData = locator
        .get<Signal<Future<AppDatabaseHandler>>>()
        .value
        .then((db) => db.appDatabase
            .getFolder(folderId: folderId)
            .then((folder) => folder!));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Folder Details"),
        actions: const [
          SearchButton(),
        ],
      ),
      body: FutureBuilder<Result<Folder>>(
        future: folderData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final result = snapshot.data;
          if (result == null) {
            return const Center(child: Text("Folder not found"));
          }

          return Column(
            children: [
              Expanded(
                child: FolderDetailInfo(folderResult: result),
              ),
              Expanded(
                child: FolderDetailItems(folderResult: result),
              ),
            ],
          );
        },
      ),
    );
  }
}
