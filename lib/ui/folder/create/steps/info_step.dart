import "package:chenron/components/TextBase/info_field.dart";
import "package:chenron/components/tags/tag_field.dart";
import "package:chenron/locator.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/ui/folder/create/create_stepper.dart";
import "package:chenron/utils/validation/folder_validator.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:signals/signals_flutter.dart";

class FolderInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ValueChanged<FolderType> onFolderTypeChanged;

  const FolderInfoStep({
    super.key,
    required this.formKey,
    required this.onFolderTypeChanged,
  });

  @override
  State<FolderInfoStep> createState() => _FolderInfoStepState();
}

class _FolderInfoStepState extends State<FolderInfoStep> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final TextEditingController _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final folderDraft = locator.get<Signal<FolderDraft>>().value.folder;

    _titleController =
        TextEditingController(text: folderDraft.folderInfo.title);
    _descriptionController =
        TextEditingController(text: folderDraft.folderInfo.description);
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
      child: Consumer(
        builder: (context, ref, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoField(
                controller: _titleController,
                labelText: "Title",
                onSaved: ref.watch(createFolderProvider.notifier).updateTitle,
                validator: FolderValidator.validateTitle,
              ),
              InfoField(
                controller: _descriptionController,
                labelText: "Description",
                onSaved:
                    ref.watch(createFolderProvider.notifier).updateDescription,
                validator: FolderValidator.validateDescription,
              ),
              const TagField(),
              const SizedBox(height: 20),
              const AccessSelection(),
              const SizedBox(height: 20),
              RepaintBoundary(
                child: FolderTypeDropDown(
                  onFolderTypeChanged: widget.onFolderTypeChanged,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AccessSelection extends StatefulWidget {
  const AccessSelection({super.key});
  @override
  State<AccessSelection> createState() => _AccessSelectionState();
}

class _AccessSelectionState extends State<AccessSelection> {
  String _access = "Private";
  @override
  Widget build(BuildContext context) {
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
  final ValueChanged<FolderType> onFolderTypeChanged;
  const FolderTypeDropDown({required this.onFolderTypeChanged, super.key});

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
        widget.onFolderTypeChanged(newValue!); // Call the callback
      },
      validator: (value) =>
          value == null ? "Please select a folder type" : null,
    );
  }
}
