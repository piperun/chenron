import "package:flutter/material.dart";
import "package:vibe/vibe.dart";

/// Data model for items to be deleted
class DeletableItem {
  final String id;
  final String title;
  final String? subtitle;

  const DeletableItem({
    required this.id,
    required this.title,
    this.subtitle,
  });
}

/// Shows a confirmation dialog before deleting items.
///
/// For bulk deletes (> 3 items), requires typing "DELETE" to confirm.
/// Returns true if user confirms, false if cancelled.
Future<bool> showDeleteConfirmationDialog({
  required BuildContext context,
  required List<DeletableItem> items,
  String? customMessage,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => DeleteConfirmationDialog(
      items: items,
      customMessage: customMessage,
    ),
  );
  return result ?? false;
}

class DeleteConfirmationDialog extends StatefulWidget {
  final List<DeletableItem> items;
  final String? customMessage;

  const DeleteConfirmationDialog({
    super.key,
    required this.items,
    this.customMessage,
  });

  @override
  State<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateConfirmation);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateConfirmation() {
    final isValid = _confirmationController.text.trim() == "DELETE";
    if (isValid != _isConfirmationValid) {
      setState(() => _isConfirmationValid = isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = widget.items.length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(count: count),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                widget.customMessage ??
                    "This action cannot be undone. The following items "
                        "will be permanently deleted:",
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Flexible(child: _ItemList(items: widget.items)),
            _DeleteConfirmationField(
              controller: _confirmationController,
              isValid: _isConfirmationValid,
            ),
            _DialogActions(
              count: count,
              canConfirm: _isConfirmationValid,
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final int count;

  const _DialogHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: colorScheme.error, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count == 1 ? "Delete Item?" : "Delete $count Items?",
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  final List<DeletableItem> items;

  const _ItemList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: colorScheme.outlineVariant,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            dense: true,
            leading:
                Icon(Icons.close_rounded, size: 20, color: colorScheme.error),
            title: Text(
              item.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: item.subtitle != null
                ? Text(
                    item.subtitle!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _DeleteConfirmationField extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;

  const _DeleteConfirmationField({
    required this.controller,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.error, width: 2),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Type DELETE to confirm:",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "DELETE",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: errorBorder,
              errorBorder: errorBorder,
              prefixIcon: Icon(Icons.keyboard, color: colorScheme.error),
              suffixIcon: isValid
                  ? Icon(Icons.check_circle, color: colorScheme.error)
                  : null,
            ),
            style: TextStyle(
              color: colorScheme.error,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
            autofocus: true,
          ),
        ],
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  final int count;
  final bool canConfirm;

  const _DialogActions({required this.count, required this.canConfirm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      // Wrap (not Row) so the buttons stack vertically when the
      // dialog is narrower than the combined width — each NierMinorButton
      // now carries a leading pointer slot, so two side-by-side
      // buttons need ~120 px more than the old TextButton/FilledButton
      // pair and can blow past a constrained dialog width.
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          NierMinorButton(
            label: "Cancel",
            onPressed: () => Navigator.of(context).pop(false),
          ),
          NierMinorButton(
            label: count == 1 ? "Delete" : "Delete All",
            destructive: true,
            onPressed:
                canConfirm ? () => Navigator.of(context).pop(true) : null,
          ),
        ],
      ),
    );
  }
}
