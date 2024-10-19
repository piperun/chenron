import "package:chenron/components/forms/link_form.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/ui/folder/create/create_stepper.dart";
import "package:flutter/material.dart";

class FolderDataStep extends StatefulWidget {
  final GlobalKey<FormState> dataKey;
  final FolderType folderType;

  const FolderDataStep({
    super.key,
    required this.dataKey,
    required this.folderType,
  });

  @override
  State<FolderDataStep> createState() => _FolderDataStepState();
}

class _FolderDataStepState extends State<FolderDataStep> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.folderType == FolderType.link)
          LinkForm(dataKey: widget.dataKey)
        //else if (widget.folderType == FolderType.document)
        //   DocumentForm(dataKey: widget.dataKey)
        // else if (widget.folderType == FolderType.folder)
        //    FolderForm(dataKey: widget.dataKey)
      ],
    );
  }
}
