import "package:chenron/components/item_list/item_list.dart";
import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/features/viewer/ui/viewer_grid_item.dart";
import "package:chenron/features/viewer/ui/viewer_list_item.dart";
import "package:chenron/models/item.dart";
import "package:chenron/utils/logger.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class ViewerContent extends StatelessWidget {
  const ViewerContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = viewerViewModelSignal.value;

    return Column(
      children: [
        Expanded(
          child: Watch.builder(
            builder: (context) {
              final snapshot = viewModel.itemsSignal.value;

              return snapshot.map(
                data: (data) {
                  return ListenableBuilder(
                    listenable: viewModel,
                    builder: (context, _) {
                      return ItemList<ViewerItem>(
                        items: data,
                        listItemBuilder: (context, item) => ViewerListItem(
                            item: item,
                            checkbox: true,
                            extraTrailingWidgets: switch (item.type) {
                              FolderItemType.folder => [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        viewModel.onEditTap(context, item.id),
                                  ),
                                ],
                              FolderItemType.link => [
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new),
                                    onPressed: () =>
                                        viewModel.onOpenUrl(item.description),
                                  ),
                                ],
                              _ => [],
                            }),
                        gridItemBuilder: (context, item) =>
                            ViewerGridItem(item: item),
                        isItemSelected: (item) =>
                            viewModel.selectedItemIds.contains(item.id),
                        extraButtons: [
                          TextButton.icon(
                            onPressed: viewModel.selectedItemIds.isEmpty
                                ? null
                                : viewModel.onDeleteSelected,
                            icon: const Icon(Icons.delete),
                            label: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) {
                  loggerGlobal.warning("ViewerUiItemStream", error);
                  return Center(child: Text("Error: $error"));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
