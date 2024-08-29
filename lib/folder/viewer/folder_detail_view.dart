import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chenron/database/database.dart';
import 'package:intl/intl.dart';

class FolderDetailView extends StatelessWidget {
  final String folderId;

  const FolderDetailView({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folder Details'),
        elevation: 0,
      ),
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
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            folder.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            folder.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Created at'),
                      subtitle: Text(
                        DateFormat('MMMM d, y HH:mm').format(folder.createdAt),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Add more folder details or related items here
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
