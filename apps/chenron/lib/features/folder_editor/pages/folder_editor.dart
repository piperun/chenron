import "package:flutter/material.dart";
import "package:chenron/components/forms/folder_form.dart";
import "package:chenron/features/folder_editor/notifiers/folder_editor_notifier.dart";
import "package:chenron/features/folder_editor/widgets/folder_items_section.dart";
import "package:signals/signals_flutter.dart";

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
  late final Signal<bool> _isFormValid;

  @override
  void initState() {
    super.initState();
    _notifier = FolderEditorNotifier();
    _isFormValid = signal(false);
    _notifier.loadFolder(widget.folderId);
  }

  @override
  void dispose() {
    _notifier.dispose();
    _isFormValid.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final success = await _notifier.saveChanges(widget.folderId);

    if (mounted) {
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
            content:
                Text(_notifier.errorMessage.value ?? "Failed to save changes"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch((context) {
      final canSave = _isFormValid.value &&
          _notifier.hasChanges.value &&
          _notifier.state.value != FolderEditorState.saving;

      return Scaffold(
        appBar: widget.hideAppBar
            ? null
            : AppBar(
                title: const Text("Edit Folder"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: canSave ? _handleSave : null,
                  ),
                ],
              ),
        body: Column(
          children: [
            if (widget.hideAppBar && widget.onClose != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      onPressed: canSave ? _handleSave : null,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text("Save"),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SectionBody(
                notifier: _notifier,
                folderId: widget.folderId,
                isFormValid: _isFormValid,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class SectionBody extends StatefulWidget {
  final FolderEditorNotifier notifier;
  final String folderId;
  final Signal<bool> isFormValid;
  const SectionBody({
    super.key,
    required this.notifier,
    required this.folderId,
    required this.isFormValid,
  });

  @override
  State<SectionBody> createState() => _SectionBodyState();
}

class _SectionBodyState extends State<SectionBody> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Watch((context) {
      switch (widget.notifier.state.value) {
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
                    widget.notifier.errorMessage.value ?? "Folder not found",
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );

        case FolderEditorState.loaded:
        case FolderEditorState.saving:
          final folder = widget.notifier.folder.value;
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
                  existingTags: folder.tags.map((t) => t.name).toSet(),
                  existingParentFolderIds: widget.notifier.formData.value?.parentFolderIds,
                  showItemsTable: false,
                  keyPrefix: "folder_editor",
                  onDataChanged: widget.notifier.updateFormData,
                  onValidationChanged: _onFormValidationChanged,
                ),
                const SizedBox(height: 24),
                FolderItemsSection(
                  folderId: widget.folderId,
                  items: widget.notifier.currentItems.value,
                  notifier: widget.notifier,
                ),
              ],
            ),
          );
      }
    });
  }

  void _onFormValidationChanged(bool isValid) {
    widget.isFormValid.value = isValid;
  }
}
