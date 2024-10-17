import "package:chenron/models/item.dart";
import "package:chenron/providers/cud_state.dart";
import "package:chenron/providers/folder_info_state.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:provider/provider.dart";

class FolderPreview extends StatelessWidget {
  final GlobalKey<FormState> previewKey;

  const FolderPreview({super.key, required this.previewKey});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ReviewCard(),
        SizedBox(height: 20),
        Expandable(),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Review Before Saving",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.blueAccent),
            ),
            const SizedBox(height: 8),
            Text(
              "Before proceeding with the save operation, please review the details below.",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class Expandable extends ConsumerWidget {
  const Expandable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderProvider = ref.watch(createFolderProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: const Text("Expand Details"),
        children: [
          ListTile(
            title: const Text("Title"),
            subtitle: Text(folderProvider.folderInfo.title),
          ),
          ListTile(
            title: const Text("Description"),
            subtitle: Text(folderProvider.folderInfo.description),
          ),
          ListTile(
            title: const Text("Tags"),
            subtitle: Text(folderProvider.tags.join(", ")),
          ),
          ListTile(
            title: const Text("Links"),
            subtitle: Text(folderProvider.items.toString()),
          ),
        ],
      ),
    );
  }
}
