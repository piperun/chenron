import "package:chenron/components/forms/folder_form.dart";
import "package:flutter/material.dart";

// TODO: FUTURE FOLDER EDITOR MIGRATION
// When implementing the new folder editor:
// 1. Create apps\chenron\lib\features\edit\folder\ structure
// 2. Use FolderForm with existingFolder: folderToEdit and showItemsTable: true
// 3. Deprecate the buggy apps\chenron\lib\features\folder_editor\ implementation
// 4. This CreateFolderPage serves as the template for the new editor structure
import "package:database/extensions/folder/create.dart";
import "package:database/extensions/folder/update.dart";
import "package:database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:database/models/cud.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/models/folder.dart";
import "package:signals/signals.dart";

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
  FolderFormData? _currentFormData;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();

    // Provide save callback to parent if requested
    widget.onSaveCallbackReady?.call(_saveFolder);

    // Initially invalid (empty form)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidationChanged?.call(false);
    });
  }

  void _onFormDataChanged(FolderFormData formData) {
    _currentFormData = formData;
  }

  void _onFormValidationChanged(bool isValid) {
    _isFormValid = isValid;
    widget.onValidationChanged?.call(isValid);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.hideAppBar
          ? null
          : AppBar(
              title: const Text("Create Folder"),
              actions: [
                IconButton(
                  key: const Key("create_folder_save_button"),
                  icon: const Icon(Icons.save),
                  onPressed: _isFormValid ? _saveFolder : null,
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
                    key: const Key("create_folder_close_button"),
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
                    key: const Key("create_folder_header_save_button"),
                    onPressed: _isFormValid ? _saveFolder : null,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text("Save"),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: FolderForm(
                  existingFolder: null, // Create mode
                  showItemsTable: false, // Not needed for folder creation
                  keyPrefix: "create_folder",
                  onDataChanged: _onFormDataChanged,
                  onValidationChanged: _onFormValidationChanged,
                  titleOverride: "Add tags to this folder",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFolder() async {
    if (!_isFormValid || _currentFormData == null) return;

    final db = locator.get<Signal<AppDatabaseHandler>>().value;
    final appDb = db.appDatabase;

    // Convert tags to Metadata objects
    final tags = _currentFormData!.tags.isNotEmpty
        ? _currentFormData!.tags
            .map((tag) => Metadata(
                  value: tag,
                  type: MetadataTypeEnum.tag,
                ))
            .toList()
        : null;

    // Create the folder
    final result = await appDb.createFolder(
      folderInfo: FolderDraft(
        title: _currentFormData!.title,
        description: _currentFormData!.description,
      ),
      tags: tags,
    );

    // Add the new folder to parent folders if any selected
    if (_currentFormData!.parentFolderIds.isNotEmpty) {
      for (final parentFolderId in _currentFormData!.parentFolderIds) {
        await appDb.updateFolder(
          parentFolderId,
          itemUpdates: CUD(
            create: [],
            update: [
              FolderItem.folder(
                id: null,
                itemId: result.folderId,
                folderId: result.folderId,
                title: _currentFormData!.title,
              )
            ],
            remove: [],
          ),
        );
      }
    }

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
