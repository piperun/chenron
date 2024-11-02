import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:flutter/material.dart";
import "package:chenron/components/item_list/layout/list.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/models/item.dart";

class ViewerListItem extends StatelessWidget {
  final ViewerItem item;
  final bool? checkbox;
  List<Widget>? extraTrailingWidgets = [];

  ViewerListItem(
      {super.key,
      required this.item,
      this.checkbox,
      this.extraTrailingWidgets});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: viewerViewModelSignal.value,
        builder: (context, _) {
          final presenter = viewerViewModelSignal.value;
          final isSelected = presenter.selectedItemIds.contains(item.id);
          return ListItem(
            onTap: () => presenter.onItemTap(context, item),
            title: Text(item.title),
            subtitle: Text(item.description),
            leading: Icon(_getIconForType(item.type)),
            trailing: OverflowBar(
              children: [
                ...extraTrailingWidgets ?? [],
                if (checkbox ?? false)
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      presenter.toggleItemSelection(item.id);
                    },
                  ),
              ],
            ),
          );
        });
  }

  IconData _getIconForType(FolderItemType type) {
    return switch (type) {
      FolderItemType.folder => Icons.folder,
      FolderItemType.link => Icons.link,
      FolderItemType.document => Icons.description,
    };
  }
}
