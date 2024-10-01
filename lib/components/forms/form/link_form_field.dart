import "package:chenron/models/item.dart";
import "package:chenron/providers/cud_state.dart";
import "package:flutter/material.dart";

class LinkFormField<T> extends FormField<T> {
  LinkFormField({
    super.key,
    required CUDProvider<FolderItem> linkProvider,
    required Widget child,
    AutovalidateMode? autovalidateMode,
    super.validator,
    super.onSaved,
  }) : super(
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          builder: (FormFieldState<T> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.hasError)
                  Text(
                    state.errorText!,
                    style: const TextStyle(color: Colors.red),
                  ),
                child,
              ],
            );
          },
        );
}
