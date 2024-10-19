import "package:chenron/components/TextBase/info_field.dart";
import "package:chenron/components/tags/tag_field.dart";
import "package:chenron/locator.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/utils/validation/folder_validator.dart";
import "package:flutter/material.dart";
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
    final folderDraft = locator.get<Signal<FolderDraft>>().value;
    return Watch.builder(
      builder: (context) => Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoField(
              controller: _titleController,
              labelText: "Title",
              onSaved: folderDraft.updateTitle,
              validator: FolderValidator.validateTitle,
            ),
            InfoField(
              controller: _descriptionController,
              labelText: "Description",
              onSaved: folderDraft.updateDescription,
              validator: FolderValidator.validateDescription,
            ),
            const TagField(),
            const SizedBox(height: 20),
            const AccessSelection(),
            const SizedBox(height: 20),
            const RepaintBoundary(
              child: FolderTypeDropDown(),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const InfoStep({required this.formKey, super.key});

  @override
  State<InfoStep> createState() => _InfoStepState();
}

class _InfoStepState extends State<InfoStep> {
  final folderDraft = locator.get<Signal<FolderDraft>>();

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (context) => LayoutBuilder(builder: (context, constraints) {
        return Form(
          key: widget.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ArchiveSelector(),
              const FolderTypeDropDown(),
              TextFormField(
                decoration: const InputDecoration(labelText: "Title"),
                onSaved: (value) =>
                    folderDraft.value.folder.folderInfo.title = value!,
                validator: FolderValidator.validateTitle,
              ),
              TextFormField(
                  decoration: const InputDecoration(labelText: "Description"),
                  onSaved: (value) =>
                      folderDraft.value.folder.folderInfo.description = value!,
                  validator: FolderValidator.validateDescription),
              const TagField(),
            ],
          ),
        );
      }),
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
  const FolderTypeDropDown({super.key});

  @override
  State<FolderTypeDropDown> createState() => _FolderTypeDropDownState();
}

class _FolderTypeDropDownState extends State<FolderTypeDropDown> {
  final _selectedFolderType =
      locator.get<Signal<FolderDraft>>().value.folder.folderType;
  static const Map<FolderType, String> _folderTypeText = {
    FolderType.link: "Link",
    FolderType.document: "Document",
    FolderType.folder: "Folder",
  };

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<FolderType>(
      decoration: const InputDecoration(labelText: "Folder type"),
      value: _selectedFolderType.value,
      items: _folderTypeText.entries.map((entry) {
        return DropdownMenuItem<FolderType>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (FolderType? newValue) {
        setState(() {
          _selectedFolderType.value = newValue;
          print("aa $_selectedFolderType");
        });
      },
      validator: (value) =>
          value == null ? "Please select a folder type" : null,
    );
  }
}

class ArchiveSelector extends StatefulWidget {
  const ArchiveSelector({super.key});

  @override
  State<ArchiveSelector> createState() => _ArchiveSelectorState();
}

class _ArchiveSelectorState extends State<ArchiveSelector> {
  final folderDraft = locator.get<Signal<FolderDraft>>();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Archive"),
      trailing: SegmentedButton<ArchiveMode>(
          selected: {folderDraft.value.folder.archiveMode.value},
          onSelectionChanged: (Set<ArchiveMode> newSelection) {
            setState(() {
              folderDraft.value.folder.archiveMode.value = newSelection.first;
            });
          },
          segments: const <ButtonSegment<ArchiveMode>>[
            ButtonSegment<ArchiveMode>(
              value: ArchiveMode.off,
              label: Text("Off"),
            ),
            ButtonSegment<ArchiveMode>(
              value: ArchiveMode.archiveIs,
              label: Text("archive.today"),
              enabled: false,
            ),
            ButtonSegment<ArchiveMode>(
              value: ArchiveMode.archiveOrg,
              label: Text("Internet archive"),
            ),
          ]),
    );
  }
}
