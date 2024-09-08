import 'package:flutter/material.dart';

class FolderFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController tagsController;
  final String access;
  final ValueChanged<String> onAccessChanged;

  const FolderFormFields({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.tagsController,
    required this.access,
    required this.onAccessChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(titleController, 'Title'),
        _buildTextField(descriptionController, 'Description'),
        _buildTextField(tagsController, 'Tags'),
        _buildAccessSelection(),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildAccessSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Access'),
        Wrap(
          spacing: 8.0,
          children: ['Private', 'Unlisted', 'Public'].map((accessType) {
            return ChoiceChip(
              label: Text(accessType),
              selected: access == accessType,
              onSelected: (bool selected) {
                onAccessChanged(accessType);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
