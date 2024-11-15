import 'package:flutter/material.dart';
import 'base_item_editor.dart';

class LinkEditor extends BaseItemEditor<String> {
  const LinkEditor({super.key, required Function(String) onAdd})
      : super(onAdd: onAdd);

  @override
  _LinkEditorState createState() => _LinkEditorState();
}

class _LinkEditorState extends State<LinkEditor> {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleAdd() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(_urlController.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Link'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _urlController,
          decoration: InputDecoration(labelText: 'URL'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a URL';
            }
            // Add more URL validation if necessary
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleAdd,
          child: Text('Add'),
        ),
      ],
    );
  }
}
