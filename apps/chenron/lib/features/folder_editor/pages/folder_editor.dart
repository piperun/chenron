import "package:chenron/database/extensions/folder/update.dart";
import "package:chenron/models/db_result.dart";
import "package:chenron/shared/folder_input/folder_input_section.dart";
import "package:chenron/shared/tag_section/tag_section.dart";
import "package:flutter/material.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/models/item.dart";
import "package:chenron/database/database.dart";
import "package:chenron/utils/validation/folder_validator.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "package:chenron/features/create/folder/widgets/folder_parent_section.dart";
import "package:chenron/features/folder_editor/widgets/folder_items_section.dart";
import "package:chenron/features/folder_editor/notifiers/folder_editor_notifier.dart";

class FolderEditor extends StatefulWidget {
  final String folderId;
  final bool hideAppBar;
  final VoidCallback? onClose;
  final VoidCallback? onSaved;

  const FolderEditor({
    super.key,
    required this.folderId,
    this.hideAppBar = false,
    this.onClose,
    this.onSaved,
  });

  @override
  State<FolderEditor> createState() => _FolderEditorState();
}

class _FolderEditorState extends State<FolderEditor> {
  late FolderEditorNotifier _notifier;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Folder> _selectedParentFolders = [];
  String? _titleError;
  String? _descriptionError;
  String? _lastFolderId;

  Stream<FolderResult?> watchFolder() async* {
    final database =
        await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
    yield* database.appDatabase.watchFolder(folderId: widget.folderId);
  }

  @override
  void initState() {
    super.initState();
    _notifier = FolderEditorNotifier();

    // Listen to notifier for validation changes
    _notifier.addListener(_onNotifierChanged);

    // Listen to text controllers
    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);
  }

  void _onNotifierChanged() {
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

    // Validate and show error inline
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

    return StreamBuilder<FolderResult?>(
      stream: watchFolder(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: widget.hideAppBar
                ? null
                : AppBar(title: const Text("Loading...")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final folderData = snapshot.data;
        if (folderData == null) {
          return Scaffold(
            appBar:
                widget.hideAppBar ? null : AppBar(title: const Text("Error")),
            body: const Center(child: Text("Folder not found")),
          );
        }

        // Initialize controllers once when data is available or when folder changes
        if (_lastFolderId != folderData.data.id) {
          _lastFolderId = folderData.data.id;
          // Use post frame callback to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _titleController.text = folderData.data.title;
              _descriptionController.text = folderData.data.description;
              _notifier.setTitle(folderData.data.title);
              _notifier.setDescription(folderData.data.description);

              // Load tags from folderData
              final tagSet = folderData.tags.map((tag) => tag.name).toSet();
              _notifier.setTags(tagSet);

              // TODO: Load parent folders - would need to query folders that contain this folder as an item
            }
          });
        }

        return Scaffold(
          appBar: widget.hideAppBar
              ? null
              : AppBar(
                  title: const Text("Edit Folder"),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _notifier.hasChanges ? _saveChanges : null,
                    ),
                  ],
                ),
          body: Column(
            children: [
              // Header with close button when in main page mode
              if (widget.hideAppBar && widget.onClose != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom:
                          BorderSide(color: theme.colorScheme.outlineVariant),
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
                        "Edit Folder",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _notifier.hasChanges ? _saveChanges : null,
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
                          description: "Add tags to organize this folder",
                          tags: _notifier.tags.value,
                          onTagAdded: _notifier.addTag,
                          onTagRemoved: _notifier.removeTag,
                        ),
                        FolderItemsSection(
                          items: folderData.items.toSet(),
                          onItemsUpdated: _handleItemEditorUpdate,
                          onAddLink: _handleAddLink,
                          onAddDocument: _handleAddDocument,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
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

    if (!_notifier.hasChanges) return;

    final database =
        await locator.get<Signal<Future<AppDatabaseHandler>>>().value;

    try {
      await database.appDatabase.updateFolder(
        widget.folderId,
        title: _titleController.text,
        description: _descriptionController.text,
        itemUpdates: _notifier.itemUpdates.value,
      );

      _notifier.resetChanges();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Changes saved successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // If onSaved callback provided, call it (main page mode)
        if (widget.onSaved != null) {
          widget.onSaved!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save changes: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAddLink() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLinkPage(
          hideAppBar: false,
          onSaved: () {
            Navigator.pop(context);
            // Refresh will happen automatically via StreamBuilder
          },
        ),
      ),
    );
  }

  void _handleAddDocument() {
    // TODO: Navigate to create document page when it exists
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Document creation not yet implemented"),
      ),
    );
  }

  void _handleItemEditorUpdate(CUD<FolderItem> updatedItems) {
    _notifier.updateItems(updatedItems);
  }
}
