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
  final bool hideAppBar;
  final ValueChanged<VoidCallback>? onSaveCallbackReady;
  final ValueChanged<bool>? onValidationChanged;
  final VoidCallback? onClose;
  final VoidCallback? onSaved;
  
  const CreateFolderPage({
    super.key,
    this.hideAppBar = false,
    this.onSaveCallbackReady,
    this.onValidationChanged,
    this.onClose,
    this.onSaved,
  });

  @override
  State<CreateFolderPage> createState() => _CreateFolderPageState();
}

class _CreateFolderPageState extends State<CreateFolderPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _access = "Private";

  @override
  void initState() {
    super.initState();
    
    // Provide save callback to parent if requested
    widget.onSaveCallbackReady?.call(saveFolder);
    
    // Add listeners to update validation state
    _titleController.addListener(_updateValidationState);
    _descriptionController.addListener(_updateValidationState);
    
    // Initially invalid (empty form) - defer to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidationChanged?.call(false);
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateValidationState);
    _descriptionController.removeListener(_updateValidationState);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateValidationState() {
    // Form is valid if title is not empty
    final isValid = _titleController.text.trim().isNotEmpty;
    widget.onValidationChanged?.call(isValid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _titleController.text.trim().isNotEmpty;
    
    return Scaffold(
      appBar: widget.hideAppBar ? null : AppBar(
        title: const Text("Create Folder"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveFolder,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with close button when in main page mode
          if (widget.hideAppBar && widget.onClose != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                    tooltip: "Close",
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Create Folder",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: isValid ? saveFolder : null,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text("Save"),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
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
          ),
        ],
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

  Future<void> saveFolder() async {
    if (_formKey.currentState!.validate()) {
      final db = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
      final appDb = db.appDatabase;

      await appDb.createFolder(
          folderInfo: FolderDraft(
        title: _titleController.text,
        description: _descriptionController.text,
      ));

      if (mounted) {
        // If onSaved callback provided, call it (main page mode)
        if (widget.onSaved != null) {
          widget.onSaved!();
        } else {
          // Otherwise, close via Navigator (modal mode)
          Navigator.pop(context);
        }
      }
    }
  }
}
