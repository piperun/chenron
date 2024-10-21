import "package:chenron/locator.dart";
import "package:chenron/models/item.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class PreviewStep extends StatelessWidget {
  const PreviewStep({super.key});

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

class Expandable extends StatelessWidget {
  const Expandable({super.key});

  @override
  Widget build(BuildContext context) {
    final folderDraft = locator.get<Signal<FolderDraft>>();

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
            subtitle: Text(folderDraft.value.folder.folderInfo.title),
          ),
          ListTile(
            title: const Text("Description"),
            subtitle: Text(folderDraft.value.folder.folderInfo.description),
          ),
          ListTile(
            title: const Text("Tags"),
            subtitle: Text(folderDraft.value.folder.tags.join(", ")),
          ),
          OverflowBar(
            children: [
              const ListTile(
                title: Text("Links"),
              ),
              SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: folderDraft.value.folder.items.length,
                  itemBuilder: (context, index) {
                    return () {
                      switch (folderDraft.value.folder.items
                          .elementAt(index)
                          .content) {
                        case StringContent link:
                          return ListTile(
                            title: Text(link.value),
                          );
                        case MapContent _:
                          return const ListTile(
                            title: Text("Map Content"),
                          );
                      }
                    }();
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
