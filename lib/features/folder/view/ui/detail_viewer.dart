import "package:chenron/components/tags/tag_body.dart";
import "package:chenron/features/folder/view/ui/detail_body.dart";
import "package:chenron/utils/logger.dart";
import "package:flutter/material.dart";
import "package:chenron/database/extensions/folder/read.dart";

class DetailViewer extends StatefulWidget {
  final Future<FolderResult> fetchData;
  final Widget Function(BuildContext, dynamic) listBuilder;

  const DetailViewer(
      {super.key, required this.fetchData, required this.listBuilder});

  @override
  State<DetailViewer> createState() => _DetailViewerState();
}

class _DetailViewerState<T> extends State<DetailViewer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FolderResult>(
      future: widget.fetchData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          loggerGlobal.severe(
              "DetailViewer", "Error loading folder: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final result = snapshot.data;
        if (result == null) {
          return const Center(child: Text("Folder not found"));
        }
        return Column(
          children: [
            Expanded(child: DetailsBody(folder: result.data)),
            if (result.tags.isNotEmpty)
              TagBody(tags: result.tags.map((tag) => tag.name).toSet()),
            const SizedBox(height: 16),
            Expanded(
              child: ItemsList(
                //HACK: list hack
                items: result.items.toList(),
                listBuilder: widget.listBuilder,
              ),
            ),
          ],
        );
      },
    );
  }
}
