import "package:flutter/material.dart";
import "package:chenron/components/forms/folder_form.dart";
import "package:chenron/features/folder_editor/notifiers/folder_editor_notifier.dart";
import "package:chenron/features/folder_editor/widgets/folder_items_section.dart";

/// Page for editing an existing folder
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
  late final FolderEditorNotifier _notifier;
  bool _isFormValid = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notifier = FolderEditorNotifier();
    _notifier.addListener(_onNotifierChanged);
    _notifier.loadFolder(widget.folderId);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onNotifierChanged);
    _notifier.dispose();
    super.dispose();
  }

  void _onNotifierChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFormValidationChanged(bool isValid) {
    setState(() {
      _isFormValid = isValid;
    });
  }

  bool get _canSave =>
      _isFormValid && _notifier.hasChanges && !_isSaving && _notifier.state != FolderEditorState.saving;

  Future<void> _handleSave() async {
    if (!_canSave) return;

    setState(() {
      _isSaving = true;
    });

    final success = await _notifier.saveChanges(widget.folderId);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Changes saved successfully"),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.onSaved != null) {
          widget.onSaved!();
        } else {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_notifier.errorMessage ?? "Failed to save changes"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.hideAppBar
          ? null
          : AppBar(
              title: const Text("Edit Folder"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _canSave ? _handleSave : null,
                ),
              ],
            ),
      body: Column(
        children: [
          // Custom header for main page mode
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
                    "Edit Folder",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _canSave ? _handleSave : null,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text("Save"),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _buildBody(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    switch (_notifier.state) {
      case FolderEditorState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case FolderEditorState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _notifier.errorMessage ?? "Folder not found",
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

      case FolderEditorState.loaded:
      case FolderEditorState.saving:
        final folder = _notifier.folder;
        if (folder == null) {
          return const Center(child: Text("Folder not found"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FolderForm(
                existingFolder: folder.data,
                showItemsTable: false,
                keyPrefix: "folder_editor",
                onDataChanged: _notifier.updateFormData,
                onValidationChanged: _onFormValidationChanged,
              ),
              const SizedBox(height: 24),
              FolderItemsSection(
                folderId: widget.folderId,
                items: _notifier.items,
                onItemsChanged: _notifier.updateItems,
              ),
            ],
          ),
        );
    }
  }
}
