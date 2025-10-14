import "package:flutter/material.dart";
import "package:chenron/utils/validation/folder_validator.dart";

class FolderInputSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? titleError;
  final String? descriptionError;

  const FolderInputSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.titleError,
    this.descriptionError,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_outlined,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Folder Information",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                hintText: "Enter folder title",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
                errorText: titleError,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "Enter folder description (optional)",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
                errorText: descriptionError,
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }
}
