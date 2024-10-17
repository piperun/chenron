import "package:chenron/components/TextBase/info_field.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/utils/validation/folder_validator.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class TagField extends ConsumerStatefulWidget {
  const TagField({super.key});

  @override
  TagFieldState createState() => TagFieldState();
}

class TagFieldState extends ConsumerState<TagField> {
  final TextEditingController _tagsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final folderInfoSetter = ref.watch(createFolderProvider.notifier);
    return Column(
      children: [
        InfoField(
          controller: _tagsController,
          labelText: "Tags",
          onFieldSubmit: (value) {
            if (FolderValidator.validateTags(value) == null) {
              folderInfoSetter.addTag(value, MetadataTypeEnum.tag);
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
            children: ref.read(createFolderProvider).tags.map((tag) {
              return InputChip(
                label: Text(tag.value),
                onDeleted: () {
                  folderInfoSetter.removeTag(tag.value);
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
