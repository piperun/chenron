import "package:chenron/components/TextBase/expandable_field.dart";
import "package:chenron/components/TextBase/text_view.dart";
import "package:chenron/components/tags/tag_body.dart";
import "package:flutter/material.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:intl/intl.dart" show DateFormat;

class DetailViewer extends StatefulWidget {
  final Future<FolderResult> fetchData;
  final Widget Function(BuildContext, dynamic) listBuilder;

  const DetailViewer(
      {super.key, required this.fetchData, required this.listBuilder});

  @override
  State<DetailViewer> createState() => _DetailViewerState();
}

class _DetailViewerState<T> extends State<DetailViewer> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Folder Details"),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
          ],
        ),
        body: FutureBuilder<FolderResult>(
          future: widget.fetchData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              //TODO: Logger
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            final result = snapshot.data;
            if (result == null) {
              return const Center(child: Text("Folder not found"));
            }
            return Column(
              children: [
                DetailsBody(folder: result.folder),
                if (result.tags.isNotEmpty)
                  TagBody(tags: result.tags.map((tag) => tag.name).toSet()),
                const SizedBox(height: 16),
                Expanded(
                  child: ItemsList(
                    items: result.items,
                    listBuilder: widget.listBuilder,
                  ),
                ),
              ],
            );
          },
        ));
  }
}

class DetailsBody extends StatelessWidget {
  final Folder folder;

  const DetailsBody({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FolderTitle(title: folder.title),
            const SizedBox(height: 8),
            FolderDescription(description: folder.description),
            FolderCreationDate(createdAt: folder.createdAt),
          ],
        ),
      ),
    );
  }
}

class FolderTitle extends StatelessWidget {
  final String title;

  const FolderTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return TextView.header(title: title);
  }
}

class FolderDescription extends StatelessWidget {
  final String description;

  const FolderDescription({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return ExpandableField(description: description);
  }
}

class FolderCreationDate extends StatelessWidget {
  final DateTime createdAt;

  const FolderCreationDate({super.key, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: TextView.listTile(
        title: "Created at",
        subtitle: DateFormat("MMMM d, y HH:mm:ss").format(createdAt),
        icon: Icons.calendar_today,
      ),
    );
  }
}

class ItemsList extends StatelessWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext, dynamic) listBuilder;

  const ItemsList({
    super.key,
    required this.items,
    required this.listBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: listBuilder(context, item),
        );
      },
    );
  }
}
