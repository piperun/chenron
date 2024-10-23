import "package:chenron/features/folder/create/ui/forms/link_form.dart";
import "package:chenron/locator.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class DataStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const DataStep({
    super.key,
    required this.formKey,
  });

  @override
  State<DataStep> createState() => _DataStepState();
}

class _DataStepState extends State<DataStep> {
  final _folderType =
      locator.get<Signal<FolderDraft>>().value.folder.folderType;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_folderType.value == FolderType.link)
          LinkForm(dataKey: widget.formKey)
        else if (_folderType.value == FolderType.document)
          const Text("Document"),
        //else if (widget.folderType == FolderType.document)
        //   DocumentForm(dataKey: widget.dataKey)
        // else if (widget.folderType == FolderType.folder)
        //    FolderForm(dataKey: widget.dataKey)
      ],
    );
  }
}
