import "package:chenron/components/TextBase/expandable_field.dart";
import "package:chenron/components/TextBase/text_view.dart";
import "package:chenron/database/database.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView.header(title: folder.title),
              ExpandableField(description: folder.description),
              FolderCreationDate(createdAt: folder.createdAt),
            ],
          ),
        ),
      ),
    );
  }
}

class FolderCreationDate extends StatelessWidget {
  final DateTime createdAt;

  const FolderCreationDate({super.key, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return TextView.listTile(
      title: "Created at",
      subtitle: DateFormat("MMMM d, y HH:mm:ss").format(createdAt),
      icon: Icons.calendar_today,
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
