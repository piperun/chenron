import "package:chenron/components/TextBase/info_field.dart";
import "package:chenron/components/tags/tag_field.dart";
import "package:chenron/providers/stepper_provider.dart";
import "package:chenron/utils/validation/folder_validator.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:chenron/providers/folder_info_state.dart";

class FolderInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const FolderInfoStep({super.key, required this.formKey});

  @override
  State<FolderInfoStep> createState() => _FolderInfoStepState();
}

class _FolderInfoStepState extends State<FolderInfoStep> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final TextEditingController _tagsController = TextEditingController();
  String _access = "Private";

  @override
  void initState() {
    super.initState();
    final folderProvider =
        Provider.of<FolderInfoProvider>(context, listen: false);
    _titleController = TextEditingController(text: folderProvider.title);
    _descriptionController =
        TextEditingController(text: folderProvider.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Consumer<FolderInfoProvider>(
        builder: (context, folderProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoField(
                controller: _titleController,
                labelText: "Title",
                onSaved: folderProvider.updateTitle,
                validator: FolderValidator.validateTitle,
              ),
              InfoField(
                controller: _descriptionController,
                labelText: "Description",
                onSaved: folderProvider.updateDescription,
                validator: FolderValidator.validateDescription,
              ),
              const TagField(),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              _buildAccessSelection(),
              const SizedBox(height: 20),
              const RepaintBoundary(
                child: FolderTypeDropDown(),
              ),
            ],
          );
        },
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
}

class FolderTypeDropDown extends StatefulWidget {
  const FolderTypeDropDown({super.key});

  @override
  State<FolderTypeDropDown> createState() => _FolderTypeDropDownState();
}

class _FolderTypeDropDownState extends State<FolderTypeDropDown> {
  FolderType? _selectedFolderType;
  static const Map<FolderType, String> _folderTypeText = {
    FolderType.link: "Link",
    FolderType.document: "Document",
    FolderType.folder: "Folder",
  };

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<FolderType>(
      decoration: const InputDecoration(labelText: "Folder type"),
      value: _selectedFolderType,
      items: _folderTypeText.entries.map((entry) {
        return DropdownMenuItem<FolderType>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (FolderType? newValue) {
        setState(() => _selectedFolderType = newValue);
      },
      validator: (value) =>
          value == null ? "Please select a folder type" : null,
    );
  }
}
