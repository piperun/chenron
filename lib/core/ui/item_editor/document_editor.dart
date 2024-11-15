import "package:flutter/material.dart";
import "base_item_editor.dart";

class DocumentEditor extends BaseItemEditor<String> {
  const DocumentEditor({super.key, required super.onAdd});

  @override
  _DocumentEditorState createState() => _DocumentEditorState();
}

class _DocumentEditorState extends State<DocumentEditor> {
  // Implement document addition logic here
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Document"),
      content: const Text("Document adding functionality goes here."),
      actions: [
        TextButton(
          onPressed: () {
            // Handle document addition
            widget.onAdd("Document Placeholder");
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
