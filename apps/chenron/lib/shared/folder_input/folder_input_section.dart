import "package:chenron/shared/labeled_text_field/labeled_text_field.dart";
import "package:chenron/shared/section_card/section_card.dart";
import "package:flutter/material.dart";

class FolderInputSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? titleError;
  final String? descriptionError;
  final String? keyPrefix;
  final List<Widget> extraChildren;

  const FolderInputSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.titleError,
    this.descriptionError,
    this.keyPrefix,
    this.extraChildren = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardSection(
      title: Text(
        "Folder information",
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      sectionIcon: const Icon(Icons.folder),
      children: [
        LabeledTextField(
          key: keyPrefix != null
              ? Key("${keyPrefix}_title_input")
              : const Key("folder_title_input"),
          controller: titleController,
          labelText: "Title",
          hintText: "Enter folder title",
          icon: const Icon(Icons.title),
          errorText: titleError,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          key: keyPrefix != null
              ? Key("${keyPrefix}_description_input")
              : const Key("folder_description_input"),
          controller: descriptionController,
          labelText: "Description",
          hintText: "Enter folder description (optional)",
          icon: const Icon(Icons.description),
          errorText: descriptionError,
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
        ...extraChildren,
      ],
    );
  }
}
