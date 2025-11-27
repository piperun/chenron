import "package:chenron/shared/search/search_button.dart";
import "package:database/extensions/folder/read.dart";
import "package:database/extensions/operations/database_file_handler.dart";
import "package:chenron/features/show_folder/widgets/folder_detail_info.dart";
import "package:chenron/features/show_folder/widgets/folder_detail_items.dart";
import "package:chenron/locator.dart";
import "package:database/models/db_result.dart" show FolderResult;
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

/// @deprecated Use FolderViewerPage from package:chenron/features/folder_viewer/pages/folder_viewer_page.dart instead.
/// This widget is deprecated and will be removed in a future version.
/// Migration: Replace ShowFolder(folderId: id) with FolderViewerPage(folderId: id)
@Deprecated(
  "Use FolderViewerPage instead. "
  "This widget will be removed in a future version. "
  "Import: package:chenron/features/folder_viewer/pages/folder_viewer_page.dart",
)
class ShowFolder extends StatelessWidget {
  final String folderId;

  const ShowFolder({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    final Future<FolderResult> folderData = locator
        .get<Signal<AppDatabaseHandler>>()
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
      body: FutureBuilder<FolderResult>(
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
