import "package:flutter/material.dart";

class InputField extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String labelText;
  final String buttonText;
  final Function()? onPressed;
  final String? Function(String?)? validator;

  const InputField({
    super.key,
    required this.formKey,
    required this.controller,
    required this.labelText,
    required this.buttonText,
    required this.onPressed,
    this.validator,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateButtonState);
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: OverflowBar(
        children: [
          FractionallySizedBox(
            widthFactor: 0.7,
            child: TextFormField(
              controller: widget.controller,
              decoration: InputDecoration(labelText: widget.labelText),
              validator: widget.validator,
            ),
          ),
          ElevatedButton(
            onPressed: _isButtonEnabled ? widget.onPressed : null,
            child: Text(widget.buttonText),
          ),
        ],
      ),
    );
  }
}
