import "package:flutter/material.dart";

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

  bool get _isBulkDelete => true; // Always require typing DELETE
  bool get _canConfirm => _isBulkDelete ? _isConfirmationValid : true;

  @override
  void initState() {
    super.initState();
    if (_isBulkDelete) {
      _confirmationController.addListener(_validateConfirmation);
    }
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
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
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
                  Icon(
                    Icons.warning_rounded,
                    color: colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.items.length == 1
                          ? "Delete Item?"
                          : "Delete ${widget.items.length} Items?",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Warning message
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                widget.customMessage ??
                    "This action cannot be undone. The following items will be permanently deleted:",
                style: theme.textTheme.bodyMedium,
              ),
            ),

            // Scrollable items list
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: colorScheme.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: colorScheme.error,
                      ),
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
              ),
            ),

            // Confirmation text field for bulk deletes
            if (_isBulkDelete)
              Padding(
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
                      controller: _confirmationController,
                      decoration: InputDecoration(
                        hintText: "DELETE",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.error,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.error,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.keyboard,
                          color: colorScheme.error,
                        ),
                        suffixIcon: _isConfirmationValid
                            ? Icon(
                                Icons.check_circle,
                                color: colorScheme.error,
                              )
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
              ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  // Delete button
                  FilledButton(
                    onPressed: _canConfirm
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    child: Text(
                      widget.items.length == 1 ? "Delete" : "Delete All",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
