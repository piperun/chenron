import "package:flutter/material.dart";
import "package:chenron/core/ui/item_editor/link_editor.dart";
import "package:chenron/core/ui/item_editor/document_editor.dart";

class ItemAdder extends StatelessWidget {
  final Function(String item) onAddLink;
  final Function(String item) onAddDocument;

  const ItemAdder({
    super.key,
    required this.onAddLink,
    required this.onAddDocument,
  });

  void _showLinkEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LinkEditor(onAdd: onAddLink),
    );
  }

  void _showDocumentEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DocumentEditor(onAdd: onAddDocument),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddOptions(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text("Add Link"),
              onTap: () {
                Navigator.of(context).pop();
                _showLinkEditor(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text("Add Document"),
              onTap: () {
                Navigator.of(context).pop();
                _showDocumentEditor(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
