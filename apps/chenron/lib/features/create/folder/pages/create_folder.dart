import "package:chenron/shared/folder_input/folder_input_section.dart";
import "package:chenron/shared/tag_section/tag_section.dart";
import "package:flutter/material.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/create.dart";
import "package:chenron/database/extensions/folder/update.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/models/folder.dart";
import "package:signals/signals.dart";
import "package:chenron/features/create/folder/notifiers/create_folder_notifier.dart";
import "package:chenron/features/create/folder/widgets/folder_parent_section.dart";
import "package:chenron/utils/validation/folder_validator.dart";

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
  late CreateFolderNotifier _notifier;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Folder> _selectedParentFolders = [];
  String? _titleError;
  String? _descriptionError;

  @override
  void initState() {
    super.initState();
    _notifier = CreateFolderNotifier();

    // Provide save callback to parent if requested
    widget.onSaveCallbackReady?.call(_saveFolder);

    // Listen to notifier for validation changes
    _notifier.addListener(_onNotifierChanged);

    // Listen to text controllers
    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);

    // Initially invalid (empty form)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidationChanged?.call(false);
    });
  }

  void _onNotifierChanged() {
    widget.onValidationChanged?.call(_notifier.isValid);
    setState(() {});
  }

  void _onTitleChanged() {
    final title = _titleController.text;
    _notifier.setTitle(title);

    // Validate and show error inline
    final error = FolderValidator.validateTitle(title);
    if (_titleError != error) {
      setState(() => _titleError = error);
    }
  }

  void _onDescriptionChanged() {
    final description = _descriptionController.text;
    _notifier.setDescription(description);

    final error = FolderValidator.validateDescription(description);
    if (_descriptionError != error) {
      setState(() => _descriptionError = error);
    }
  }

  @override
  void dispose() {
    _notifier.removeListener(_onNotifierChanged);
    _titleController.removeListener(_onTitleChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _notifier.dispose();
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
                  key: const Key('create_folder_save_button'),
                  icon: const Icon(Icons.save),
                  onPressed: _notifier.isValid ? _saveFolder : null,
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
                    key: const Key('create_folder_close_button'),
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
                    key: const Key('create_folder_header_save_button'),
                    onPressed: _notifier.isValid ? _saveFolder : null,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FolderInputSection(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      titleError: _titleError,
                      descriptionError: _descriptionError,
                    ),
                    FolderParentSection(
                      selectedFolders: _selectedParentFolders,
                      onFoldersChanged: (folders) {
                        setState(() {
                          _selectedParentFolders = folders;
                          _notifier.setParentFolders(
                            folders.map((f) => f.id).toList(),
                          );
                        });
                      },
                    ),
                    TagSection(
                      keyPrefix: 'folder_tags',
                      description: "Add tags to this folder",
                      tags: _notifier.tags.value,
                      onTagAdded: _notifier.addTag,
                      onTagRemoved: _notifier.removeTag,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFolder() async {
    // Validate before saving
    final titleError = FolderValidator.validateTitle(_titleController.text);
    final descriptionError =
        FolderValidator.validateDescription(_descriptionController.text);

    if (titleError != null || descriptionError != null) {
      setState(() {
        _titleError = titleError;
        _descriptionError = descriptionError;
      });
      return;
    }

    if (!_notifier.isValid) return;

    final db = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
    final appDb = db.appDatabase;

    // Convert tags to Metadata objects
    final tags = _notifier.tags.value.isNotEmpty
        ? _notifier.tags.value
            .map((tag) => Metadata(
                  value: tag,
                  type: MetadataTypeEnum.tag,
                ))
            .toList()
        : null;

    // Create the folder
    final result = await appDb.createFolder(
      folderInfo: FolderDraft(
        title: _notifier.title.value,
        description: _notifier.description.value,
      ),
      tags: tags,
    );

    // Add the new folder to parent folders if any selected
    if (_selectedParentFolders.isNotEmpty) {
      for (final parentFolder in _selectedParentFolders) {
        await appDb.updateFolder(
          parentFolder.id,
          itemUpdates: CUD(
            create: [],
            update: [
              FolderItem(
                type: FolderItemType.folder,
                itemId: result.folderId,
                content: StringContent(value: _notifier.title.value),
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
