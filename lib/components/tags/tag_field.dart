import "package:chenron/components/TextBase/info_field.dart";
import "package:chenron/providers/folder_info_state.dart";
import "package:chenron/utils/validation/folder_validator.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class TagField extends StatefulWidget {
  const TagField({super.key});

  @override
  State<TagField> createState() => _TagFieldState();
}

class _TagFieldState extends State<TagField> {
  final TextEditingController _tagsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final folderInfo = Provider.of<FolderInfoProvider>(context);
    return Column(
      children: [
        InfoField(
          controller: _tagsController,
          labelText: "Tags",
          onFieldSubmit: (value) {
            if (FolderValidator.validateTags(value) == null) {
              folderInfo.addTag(value);
              setState(() {
                _tagsController.clear();
              });
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            spacing: 8.0,
            children: folderInfo.tags.map((tag) {
              return InputChip(
                label: Text(tag),
                onDeleted: () {
                  folderInfo.removeTag(tag);
                },
                deleteIconColor: Colors.red.withOpacity(0.66),
                backgroundColor:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                labelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
