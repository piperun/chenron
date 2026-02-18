import "dart:async";
import "package:chenron/shared/folder_input/folder_input_section.dart";
import "package:chenron/shared/tag_section/tag_section.dart";
import "package:chenron/shared/color_picker/color_picker_field.dart";
import "package:chenron/features/create/folder/widgets/folder_parent_section.dart";
import "package:database/main.dart";
import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:chenron/utils/validation/folder_validator.dart";
import "package:chenron/features/create/folder/services/folder_persistence_service.dart";
import "package:signals/signals.dart";

/// Form model that represents the folder data
class FolderFormData {
  final String title;
  final String description;
  final int? color;
  final List<String> parentFolderIds;
  final Set<String> tags;
  final List<FolderItem> items;

  const FolderFormData({
    required this.title,
    required this.description,
    this.color,
    required this.parentFolderIds,
    required this.tags,
    required this.items,
  });

  FolderFormData copyWith({
    String? title,
    String? description,
    Object? color = _sentinel,
    List<String>? parentFolderIds,
    Set<String>? tags,
    List<FolderItem>? items,
  }) {
    return FolderFormData(
      title: title ?? this.title,
      description: description ?? this.description,
      color: color == _sentinel ? this.color : color as int?,
      parentFolderIds: parentFolderIds ?? this.parentFolderIds,
      tags: tags ?? this.tags,
      items: items ?? this.items,
    );
  }
}

const _sentinel = Object();

/// Reusable folder form component that handles both create and edit modes
class FolderForm extends StatefulWidget {
  final Folder? existingFolder;
  final Set<String>? existingTags;
  final List<String>? existingParentFolderIds;
  final String? keyPrefix;
  final ValueChanged<FolderFormData>? onDataChanged;
  final ValueChanged<bool>? onValidationChanged;
  final String? titleOverride;
  final String? descriptionOverride;

  const FolderForm({
    super.key,
    this.existingFolder,
    this.existingTags,
    this.existingParentFolderIds,
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
  List<Folder> _selectedParentFolders = [];
  Set<String> _tags = {};
  int? _color;
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
    _color = widget.existingFolder?.color;

    // Initialize tags if provided
    if (widget.existingTags != null) {
      _tags = widget.existingTags!;
      _tagsSignal.value = _tags;
    }

    // Load existing parent folders if provided
    if (widget.existingParentFolderIds != null &&
        widget.existingParentFolderIds!.isNotEmpty) {
      unawaited(_loadParentFolders(widget.existingParentFolderIds!));
    }

    // Listen to text controllers
    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);

    // Initial validation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateAndNotify();
    });
  }

  Future<void> _loadParentFolders(List<String> folderIds) async {
    try {
      final folders =
          await FolderPersistenceService().loadFoldersByIds(folderIds);

      if (mounted && folders.isNotEmpty) {
        setState(() {
          _selectedParentFolders = folders;
        });
        _validateAndNotify();
      }
    } catch (e) {
      // Silently fail - parent folders are optional
    }
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

  bool get _isValid =>
      _title.value.trim().isNotEmpty &&
      _titleError == null &&
      _descriptionError == null;

  void _onColorChanged(int? color) {
    setState(() => _color = color);
    _validateAndNotify();
  }

  void _validateAndNotify() {
    final formData = FolderFormData(
      title: _title.value,
      description: _description.value,
      color: _color,
      parentFolderIds: _selectedParentFolders.map((f) => f.id).toList(),
      tags: _tags,
      items: const [],
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
          extraChildren: [
            const SizedBox(height: 16),
            ColorPickerField(
              currentColor: _color,
              onColorChanged: _onColorChanged,
            ),
          ],
        ),
        FolderParentSection(
          selectedFolders: _selectedParentFolders,
          onFoldersChanged: _onParentFoldersChanged,
          currentFolderId: widget.existingFolder?.id,
        ),
        TagSection(
          keyPrefix: widget.keyPrefix != null
              ? "${widget.keyPrefix}_tags"
              : "folder_tags",
          description: widget.titleOverride ?? "Add tags to this folder",
          tags: _tags,
          onTagAdded: _onTagAdded,
          onTagRemoved: _onTagRemoved,
        ),
      ],
    );
  }
}
