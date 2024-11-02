import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:flutter/material.dart";

class ViewerToolbar extends StatelessWidget {
  final ViewLayout layout;
  final ValueChanged<ViewLayout> onLayoutChanged;
  final VoidCallback onDeleteSelected;

  const ViewerToolbar({
    super.key,
    required this.layout,
    required this.onLayoutChanged,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ListenableBuilder(
              listenable: viewerViewModelSignal.value,
              builder: (context, _) {
                final presenter = viewerViewModelSignal.value;
                final hasSelectedItems = presenter.selectedItemIds.isNotEmpty;

                if (!hasSelectedItems) return const SizedBox.shrink();

                return TextButton.icon(
                  icon: const Icon(Icons.delete),
                  onPressed: onDeleteSelected,
                  label: const Text("Delete items"),
                );
              }),
          IconButton(
            icon:
                Icon(layout == ViewLayout.grid ? Icons.list : Icons.grid_view),
            onPressed: () => onLayoutChanged(
              layout == ViewLayout.grid ? ViewLayout.list : ViewLayout.grid,
            ),
            tooltip: layout == ViewLayout.grid ? "List view" : "Grid view",
          ),
        ],
      ),
    );
  }
}
