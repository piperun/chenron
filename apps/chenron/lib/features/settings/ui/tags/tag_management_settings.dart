import "dart:async";

import "package:chenron/features/settings/ui/shared/settings_section_header.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/color_picker/color_dot.dart";
import "package:chenron/shared/dialogs/confirm_dialog.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:chenron/utils/safe_async.dart";
import "package:chenron/utils/validation/tag_validator.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter/material.dart";
import "package:signals/signals.dart";

class TagManagementSettings extends StatefulWidget {
  const TagManagementSettings({super.key});

  @override
  State<TagManagementSettings> createState() => _TagManagementSettingsState();
}

class _TagManagementSettingsState extends State<TagManagementSettings> {
  List<TagResult> _tags = [];
  bool _isLoading = true;
  StreamSubscription<List<TagResult>>? _subscription;

  AppDatabase get _db =>
      locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;

  @override
  void initState() {
    super.initState();
    _subscription = safeWatch<List<TagResult>>(
      _db.watchAllTags(),
      tag: "TagManagementSettings",
      onData: (tags) {
        if (!mounted) return;
        final sorted = List<TagResult>.from(tags)
          ..sort((a, b) => a.data.name.compareTo(b.data.name));
        setState(() {
          _tags = sorted;
          _isLoading = false;
        });
      },
      onUiError: (_) {
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  Future<void> _handleColorChange(String tagName, int? color) async {
    await safeAwait<void>(
      tag: "TagManagementSettings",
      operation: "update tag color",
      action: () => _db.updateTagColor(tagName: tagName, color: color),
    );
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> _handleRename(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Tag"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Tag name",
              border: OutlineInputBorder(),
            ),
            validator: TagValidator.validateTag,
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );

    controller.dispose();

    if (newName == null || newName == currentName) return;

    try {
      await _db.renameTag(oldName: currentName, newName: newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tag renamed to '$newName'"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Unique constraint violation means the name already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tag '$newName' already exists"),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(String tagId) async {
    // Find the tag name for display in the dialog
    final tag = _tags.where((t) => t.data.id == tagId).firstOrNull;
    if (tag == null) return;
    final tagName = tag.data.name;

    final confirmed = await showConfirmDialog(
      context,
      title: "Delete tag '$tagName'?",
      message: "This will remove the tag from all items. "
          "This action cannot be undone.",
      confirmLabel: "Delete",
      destructive: true,
    );

    if (!confirmed) return;

    try {
      await _db.removeTag(tagId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tag '$tagName' deleted"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsSectionHeader(
          title: "All Tags",
          description: "Manage your tags — rename, delete, or change colors.",
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_tags.isEmpty)
          Text(
            "No tags yet.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          )
        else
          ...List.generate(_tags.length, (i) {
            final tag = _tags[i];
            return _TagManagementRow(
              tagName: tag.data.name,
              tagColor: tag.data.color,
              onColorChanged: (color) =>
                  unawaited(_handleColorChange(tag.data.name, color)),
              onRename: () => unawaited(_handleRename(tag.data.name)),
              onDelete: () => unawaited(_handleDelete(tag.data.id)),
            );
          }),
      ],
    );
  }
}

class _TagManagementRow extends StatelessWidget {
  final String tagName;
  final int? tagColor;
  final ValueChanged<int?> onColorChanged;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _TagManagementRow({
    required this.tagName,
    required this.tagColor,
    required this.onColorChanged,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ColorDot(
            currentColor: tagColor,
            onColorChanged: onColorChanged,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tagName,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onRename,
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: "Rename",
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: theme.colorScheme.error,
            ),
            tooltip: "Delete",
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}