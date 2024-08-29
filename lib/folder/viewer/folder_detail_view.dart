import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chenron/database/database.dart';

class FolderDetailView extends StatelessWidget {
  final String folderId;

  const FolderDetailView({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Folder Details')),
      body: FutureBuilder<Folder?>(
        future: database.folders.findById(folderId).getSingleOrNull(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final folder = snapshot.data;
          if (folder == null) {
            return const Center(child: Text('Folder not found'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${folder.title}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Description: ${folder.description}'),
                const SizedBox(height: 16),
                Text('Created at: ${folder.createdAt}'),
                const SizedBox(height: 16),
                // Add more folder details or related items here
              ],
            ),
          );
        },
      ),
    );
  }
}
