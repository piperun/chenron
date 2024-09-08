import 'package:chenron/components/forms/link_form.dart';
import 'package:chenron/folder/create/steps/folder_info.dart';
import 'package:flutter/material.dart';

class FolderData extends StatefulWidget {
  final GlobalKey<FormState> dataKey;
  const FolderData(
      {super.key, required this.dataKey, required FolderType? folderType});

  @override
  State<FolderData> createState() => _FolderDataState();
}

class _FolderDataState extends State<FolderData> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinkForm(
          dataKey: widget.dataKey,
        )
      ],
    );
  }
}
