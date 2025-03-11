import "package:chenron/components/TextBase/info_field.dart";
import "package:chenron/components/tags/tag_field.dart";
import "package:chenron/database/extensions/folder/create.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/folder.dart";
import "package:chenron/utils/validation/folder_validator.dart";
import "package:flutter/material.dart";
import "package:signals/signals.dart";

enum FolderType { folder, link, document }

class CreateFolderPage extends StatefulWidget {
  const CreateFolderPage({super.key});

  @override
  State<CreateFolderPage> createState() => _CreateFolderPageState();
}

class _CreateFolderPageState extends State<CreateFolderPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _access = "Private";

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Folder"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFolder,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoField(
                controller: _titleController,
                labelText: "Title",
                validator: FolderValidator.validateTitle,
              ),
              InfoField(
                controller: _descriptionController,
                labelText: "Description",
                validator: FolderValidator.validateDescription,
              ),
              const TagField(),
              const SizedBox(height: 20),
              _buildAccessSelection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Access"),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: ["Private", "Unlisted", "Public"].map((accessType) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(accessType),
                selected: _access == accessType,
                onSelected: (bool selected) {
                  setState(() => _access = accessType);
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveFolder() async {
    if (_formKey.currentState!.validate()) {
      final db = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
      final appDb = db.appDatabase;

      await appDb.createFolder(
          folderInfo: FolderDraft(
        title: _titleController.text,
        description: _descriptionController.text,
      ));

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
