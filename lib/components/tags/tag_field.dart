import "package:chenron/components/TextBase/info_field.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/utils/validation/folder_validator.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class TagField extends StatefulWidget {
  const TagField({super.key});

  @override
  State<TagField> createState() => _TagFieldState();
}

class _TagFieldState extends State<TagField> {
  final TextEditingController _tagsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final folderDraft = locator.get<Signal<FolderDraft>>().value;
    return Column(
      children: [
        InfoField(
          controller: _tagsController,
          labelText: "Tags",
          onFieldSubmit: (value) {
            if (FolderValidator.validateTags(value) == null) {
              folderDraft.addTag(value, MetadataTypeEnum.tag);
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
            children: folderDraft.folder.tags.map((tag) {
              return InputChip(
                label: Text(tag.value),
                onDeleted: () {
                  folderDraft.removeTag(tag.value);
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
