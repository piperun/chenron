import "package:chenron/components/forms/link_form.dart";
import "package:chenron/providers/stepper_provider.dart";
import "package:flutter/material.dart";

class FolderDataStep extends StatefulWidget {
  final GlobalKey<FormState> dataKey;
  const FolderDataStep(
      {super.key, required this.dataKey, required FolderType? folderType});

  @override
  State<FolderDataStep> createState() => _FolderDataStepState();
}

class _FolderDataStepState extends State<FolderDataStep> {
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
