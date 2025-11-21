import "dart:async";
import "package:flutter/material.dart";
import "package:flutter_colorpicker/flutter_colorpicker.dart";

class ColorPickerTile extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final String title;

  const ColorPickerTile({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.title = "Select Color",
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: CircleAvatar(
        backgroundColor: pickerColor,
        radius: 15,
      ),
      onTap: () => _showColorPicker(context),
    );
  }

  void _showColorPicker(BuildContext context) {
    Color tempColor = pickerColor;

    unawaited(showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Select"),
              onPressed: () {
                onColorChanged(tempColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ));
  }
}
