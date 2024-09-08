import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chenron/providers/folder_info_state.dart';

// move this to somewhere else to be used by other widgets
enum FolderType { link, document, folder }

class FolderInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const FolderInfoStep({super.key, required this.formKey});

  @override
  _FolderInfoStepState createState() => _FolderInfoStepState();
}

class _FolderInfoStepState extends State<FolderInfoStep> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final TextEditingController _tagsController = TextEditingController();
  String _access = 'Private';
  FolderType? _selectedFolderType;

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

  static const Map<FolderType, String> _folderTypeText = {
    FolderType.link: 'Link',
    FolderType.document: 'Document',
    FolderType.folder: 'Folder',
  };

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Consumer<FolderInfoProvider>(
        builder: (context, folderProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFormField(
                controller: _titleController,
                labelText: 'Title',
                onSaved: folderProvider.updateTitle,
                validator: _validateNotEmpty,
              ),
              _buildTextFormField(
                controller: _descriptionController,
                labelText: 'Description',
                onSaved: folderProvider.updateDescription,
                validator: _validateNotEmpty,
              ),
              _buildTextFormField(
                controller: _tagsController,
                labelText: 'Tags',
                validator: _validateNotEmpty,
              ),
              const SizedBox(height: 20),
              _buildOptionButton(),
              const SizedBox(height: 20),
              _buildAccessSelection(),
              const SizedBox(height: 20),
              _buildFolderTypeDropdown(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    Function(String)? onSaved,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      onSaved: onSaved != null ? (value) => onSaved(value!) : null,
      validator: validator,
    );
  }

  Widget _buildOptionButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Handle button press logic
      },
      icon: const Icon(Icons.category),
      label: const Text('Option 1'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.teal,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAccessSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Access'),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: ['Private', 'Unlisted', 'Public'].map((accessType) {
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

  Widget _buildFolderTypeDropdown() {
    return DropdownButtonFormField<FolderType>(
      decoration: const InputDecoration(labelText: 'Folder type'),
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
          value == null ? 'Please select a folder type' : null,
    );
  }

  String? _validateNotEmpty(String? value) {
    return value == null || value.isEmpty ? 'This field cannot be empty' : null;
  }
}
