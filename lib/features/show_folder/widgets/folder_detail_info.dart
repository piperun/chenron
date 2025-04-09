import "package:chenron/components/TextBase/expandable_field.dart";
import "package:chenron/components/TextBase/text_view.dart";
import "package:chenron/components/tags/tag_body.dart";
import "package:chenron/models/db_result.dart" show FolderResult;
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class FolderDetailInfo extends StatelessWidget {
  final FolderResult folderResult;

  const FolderDetailInfo({super.key, required this.folderResult});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
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
                TextView.header(title: folderResult.data.title),
                ExpandableField(description: folderResult.data.description),
                FolderCreationDate(createdAt: folderResult.data.createdAt),
                if (folderResult.tags.isNotEmpty)
                  TagBody(
                      tags: folderResult.tags.map((tag) => tag.name).toSet()),
              ],
            ),
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
