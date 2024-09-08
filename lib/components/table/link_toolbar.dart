import 'package:flutter/material.dart';

class LinkToolbar extends StatelessWidget {
  final void Function()? onDelete;
  const LinkToolbar({super.key, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
        margin: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
                child: TextField(
                    decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter a search term',
              isDense: true,
            ))),
            const Spacer(),
            ElevatedButton.icon(
                icon: const Icon(
                  Icons.highlight_remove,
                  color: Colors.red,
                  size: 30.0,
                ),
                label: const Text('Remove selected'),
                onPressed: onDelete),
          ],
        ));
  }
}
