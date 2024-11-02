import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:flutter/material.dart";
import "package:chenron/components/item_list/layout/grid.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/models/item.dart";

class ViewerGridItem extends StatelessWidget {
  final ViewerItem item;

  const ViewerGridItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: viewerViewModelSignal.value,
        builder: (context, _) {
          final presenter = viewerViewModelSignal.value;
          final isSelected = presenter.selectedItemIds.contains(item.id);
          return GridItem(
            onTap: () => presenter.onItemTap(context, item),
            header: GridHeader(
              leading: Text(item.title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      presenter.toggleItemSelection(item.id);
                    },
                  ),
                  Icon(_getIconForType(item.type)),
                ],
              ),
            ),
            body: Text(item.description),
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
