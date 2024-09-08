import 'package:chenron/database/extensions/folder/update.dart';
import 'package:chenron/folder/create/steps/folder_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chenron/database/database.dart';
import 'package:intl/intl.dart';

enum FolderFormMode { create, edit, view }

class FolderFormView extends StatefulWidget {
  final String? folderId;
  FolderFormMode mode;

  FolderFormView({
    super.key,
    this.folderId,
    required this.mode,
  });

  @override
  _FolderFormViewState createState() => _FolderFormViewState();
}

class _FolderFormViewState extends State<FolderFormView> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final TextEditingController _tagsController = TextEditingController();
  String _access = 'Private';
  FolderType? _selectedFolderType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    if (widget.mode != FolderFormMode.create) {
      _loadFolderData();
    }
  }

  void _loadFolderData() async {
    final database = Provider.of<AppDatabase>(context, listen: false);
    final folder =
        await database.folders.findById(widget.folderId!).getSingleOrNull();
    if (folder != null) {
      setState(() {
        _titleController.text = folder.title;
        _descriptionController.text = folder.description;
        // Load other fields as needed
      });
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == FolderFormMode.create
            ? 'Create Folder'
            : 'Folder Details'),
        actions: [
          if (widget.mode == FolderFormMode.edit)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _saveFolder(context, widget.folderId!),
            ),
          if (widget.mode == FolderFormMode.view)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  setState(() => widget.mode = FolderFormMode.edit),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_titleController, 'Title'),
            _buildTextField(_descriptionController, 'Description'),
            if (widget.mode != FolderFormMode.view) ...[
              _buildTextField(_tagsController, 'Tags'),
              _buildAccessSelection(),
            ],
            if (widget.mode == FolderFormMode.create)
              _buildFolderTypeDropdown(),
            if (widget.mode == FolderFormMode.view && widget.folderId != null)
              _buildCreationDate(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      enabled: widget.mode != FolderFormMode.view,
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
              selected: _access == accessType,
              onSelected: (bool selected) {
                setState(() => _access = accessType);
              },
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
      items: FolderType.values.map((type) {
        return DropdownMenuItem<FolderType>(
          value: type,
          child: Text(type.toString().split('.').last),
        );
      }).toList(),
      onChanged: (FolderType? newValue) {
        setState(() => _selectedFolderType = newValue);
      },
    );
  }

  Widget _buildCreationDate() {
    return FutureBuilder<Folder?>(
      future: Provider.of<AppDatabase>(context, listen: false)
          .folders
          .findById(widget.folderId!)
          .getSingleOrNull(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Created at'),
            subtitle: Text(
              DateFormat('MMMM d, y HH:mm').format(snapshot.data!.createdAt),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _saveFolder(BuildContext context, String folderId) async {
    final database = Provider.of<AppDatabase>(context, listen: false);

    final originalFolder =
        await database.folders.findById(folderId).getSingleOrNull();

    if (originalFolder != null) {
      //TODO: We should have FolderInfo class which will happen when we refactor things.
      final hasChanges = originalFolder.title != _titleController.text ||
          originalFolder.description != _descriptionController.text; //||
      //originalFolder.access != _access ||

      if (hasChanges) {
        await database.updateFolder(
          folderId,
          title: _titleController.text,
          description: _descriptionController.text,
          //access: _access,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder saved successfully')),
          );
        }
      }
    }
  }
}
