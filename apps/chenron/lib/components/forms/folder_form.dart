import "package:chenron/shared/folder_input/folder_input_section.dart";
import "package:chenron/shared/tag_section/tag_section.dart";
import "package:chenron/features/create/folder/widgets/folder_parent_section.dart";
import "package:chenron/notifiers/item_table_notifier.dart";
import "package:flutter/material.dart";
import "package:chenron/database/database.dart";
import "package:chenron/models/item.dart";
import "package:chenron/utils/validation/folder_validator.dart";
import "package:signals/signals.dart";

/// Form model that represents the folder data
class FolderFormData {
  final String title;
  final String description;
  final List<String> parentFolderIds;
  final Set<String> tags;
  final List<FolderItem> items;

  const FolderFormData({
    required this.title,
    required this.description,
    required this.parentFolderIds,
    required this.tags,
    required this.items,
  });

  FolderFormData copyWith({
    String? title,
    String? description,
    List<String>? parentFolderIds,
    Set<String>? tags,
    List<FolderItem>? items,
  }) {
    return FolderFormData(
      title: title ?? this.title,
      description: description ?? this.description,
      parentFolderIds: parentFolderIds ?? this.parentFolderIds,
      tags: tags ?? this.tags,
      items: items ?? this.items,
    );
  }
}

/// Reusable folder form component that handles both create and edit modes
class FolderForm extends StatefulWidget {
  final Folder? existingFolder;
  final Set<String>? existingTags;
  final bool showItemsTable;
  final String? keyPrefix;
  final ValueChanged<FolderFormData>? onDataChanged;
  final ValueChanged<bool>? onValidationChanged;
  final String? titleOverride;
  final String? descriptionOverride;

  const FolderForm({
    super.key,
    this.existingFolder,
    this.existingTags,
    this.showItemsTable = false,
    this.keyPrefix,
    this.onDataChanged,
    this.onValidationChanged,
    this.titleOverride,
    this.descriptionOverride,
  });

  @override
  State<FolderForm> createState() => _FolderFormState();
}

class _FolderFormState extends State<FolderForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final ItemTableNotifier _tableNotifier = ItemTableNotifier();
  
  List<Folder> _selectedParentFolders = [];
  Set<String> _tags = {};
  final List<FolderItem> _items = [];
  String? _titleError;
  String? _descriptionError;

  // Signals for reactive state management
  final Signal<String> _title = signal("");
  final Signal<String> _description = signal("");
  final Signal<Set<String>> _tagsSignal = signal({});

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data if editing
    final initialTitle = widget.existingFolder?.title ?? "";
    final initialDescription = widget.existingFolder?.description ?? "";
    
    _titleController = TextEditingController(text: initialTitle);
    _descriptionController = TextEditingController(text: initialDescription);
    
    // Initialize state
    _title.value = initialTitle;
    _description.value = initialDescription;
    
    // Initialize tags if provided
    if (widget.existingTags != null) {
      _tags = widget.existingTags!;
      _tagsSignal.value = _tags;
    }
    
    // TODO: Load existing parent folders when editing
    // This would require additional database queries to fetch relationships
    
    // Listen to text controllers
    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);
    
    // Initial validation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateAndNotify();
    });
  }

  void _onTitleChanged() {
    final title = _titleController.text;
    _title.value = title;
    
    // Validate and show error inline
    final error = FolderValidator.validateTitle(title);
    if (_titleError != error) {
      setState(() => _titleError = error);
    }
    
    _validateAndNotify();
  }

  void _onDescriptionChanged() {
    final description = _descriptionController.text;
    _description.value = description;
    
    final error = FolderValidator.validateDescription(description);
    if (_descriptionError != error) {
      setState(() => _descriptionError = error);
    }
    
    _validateAndNotify();
  }

  void _onParentFoldersChanged(List<Folder> folders) {
    setState(() {
      _selectedParentFolders = folders;
    });
    _validateAndNotify();
  }

  void _onTagAdded(String tag) {
    final cleanTag = tag.trim().toLowerCase();
    if (cleanTag.isNotEmpty && !_tags.contains(cleanTag)) {
      setState(() {
        _tags = {..._tags, cleanTag};
        _tagsSignal.value = _tags;
      });
      _validateAndNotify();
    }
  }

  void _onTagRemoved(String tag) {
    if (_tags.contains(tag)) {
      setState(() {
        _tags = {..._tags}..remove(tag);
        _tagsSignal.value = _tags;
      });
      _validateAndNotify();
    }
  }

  bool get _isValid => _title.value.trim().isNotEmpty && 
                       _titleError == null && 
                       _descriptionError == null;

  void _validateAndNotify() {
    final formData = FolderFormData(
      title: _title.value,
      description: _description.value,
      parentFolderIds: _selectedParentFolders.map((f) => f.id).toList(),
      tags: _tags,
      items: _items,
    );

    widget.onDataChanged?.call(formData);
    widget.onValidationChanged?.call(_isValid);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _title.dispose();
    _description.dispose();
    _tagsSignal.dispose();
    _tableNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FolderInputSection(
          titleController: _titleController,
          descriptionController: _descriptionController,
          titleError: _titleError,
          descriptionError: _descriptionError,
          keyPrefix: widget.keyPrefix,
        ),
        FolderParentSection(
          selectedFolders: _selectedParentFolders,
          onFoldersChanged: _onParentFoldersChanged,
        ),
        TagSection(
          keyPrefix: widget.keyPrefix != null ? "${widget.keyPrefix}_tags" : "folder_tags",
          description: widget.titleOverride ?? "Add tags to this folder",
          tags: _tags,
          onTagAdded: _onTagAdded,
          onTagRemoved: _onTagRemoved,
        ),
        // TODO: Add DataGrid/ItemTable integration when showItemsTable is true
        // This will allow managing folder items in edit mode
        // FUTURE: When implementing folder editor, this section will use:
        // - DataGrid component from apps\chenron\lib\components\tables\item_table.dart
        // - ItemTableNotifier for state management
        // - Support for adding/removing/editing folder items
        // - Integration with the existing folder item CRUD operations
        if (widget.showItemsTable) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Folder Items",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // TODO: Implement DataGrid here
                  // This would show existing folder items and allow adding/removing items
                  const Text(
                    "Item management will be implemented here using DataGrid component",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}