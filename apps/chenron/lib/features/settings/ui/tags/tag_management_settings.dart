import "dart:async";

import "package:chenron/locator.dart";
import "package:chenron/shared/dialogs/tag_color_picker.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:chenron/utils/validation/tag_validator.dart";
import "package:database/database.dart";
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
      locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;

  @override
  void initState() {
    super.initState();
    _subscription = _db.watchAllTags().listen((tags) {
      if (!mounted) return;
      final sorted = List<TagResult>.from(tags)
        ..sort((a, b) => a.data.name.compareTo(b.data.name));
      setState(() {
        _tags = sorted;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> _handleColorChange(String tagName, int? color) async {
    await _db.updateTagColor(tagName: tagName, color: color);
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete tag '$tagName'?"),
        content: const Text(
          "This will remove the tag from all items. "
          "This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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
        Text("All Tags", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          "Manage your tags — rename, delete, or change colors.",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
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
          _TagColorDot(
            tagColor: tagColor,
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

class _TagColorDot extends StatelessWidget {
  final int? tagColor;
  final ValueChanged<int?> onColorChanged;

  const _TagColorDot({
    required this.tagColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapUp: (details) async {
        final box = context.findRenderObject()! as RenderBox;
        final overlay =
            Overlay.of(context).context.findRenderObject()! as RenderBox;
        final position = RelativeRect.fromRect(
          Rect.fromPoints(
            box.localToGlobal(Offset.zero, ancestor: overlay),
            box.localToGlobal(box.size.bottomRight(Offset.zero),
                ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );

        final result = await showTagColorPicker(
          context: context,
          anchor: position,
          currentColor: tagColor,
        );
        if (result != null) {
          onColorChanged(result.color);
        }
      },
      child: Icon(
        Icons.sell,
        size: 18,
        color: tagColor != null
            ? Color(tagColor!)
            : theme.colorScheme.outlineVariant,
      ),
    );
  }
}
