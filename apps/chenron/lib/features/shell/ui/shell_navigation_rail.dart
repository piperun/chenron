import "package:flutter/material.dart";
import "package:chenron/features/create/folder/pages/create_folder.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "dart:math" as math;

class ShellNavigationRail extends StatelessWidget {
  final bool isExtended;
  final int? selectedIndex;
  final List<NavigationRailDestination> destinations;
  final Function(int) onDestinationSelected;
  final VoidCallback onToggleExtended;
  final Function(BuildContext, Widget, String) onNavigateToCreate;

  const ShellNavigationRail({
    super.key,
    required this.isExtended,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.onToggleExtended,
    required this.onNavigateToCreate,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: isExtended,
      minExtendedWidth: 180,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      leading: _NavigationRailLeading(
        isExtended: isExtended,
        onToggleExtended: onToggleExtended,
        onNavigateToCreate: onNavigateToCreate,
      ),
      destinations: destinations,
    );
  }
}

class _NavigationRailLeading extends StatelessWidget {
  final bool isExtended;
  final VoidCallback onToggleExtended;
  final Function(BuildContext, Widget, String) onNavigateToCreate;

  const _NavigationRailLeading({
    required this.isExtended,
    required this.onToggleExtended,
    required this.onNavigateToCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          tooltip: isExtended ? "Collapse Navigation" : "Expand Navigation",
          icon: Icon(isExtended ? Icons.menu_open : Icons.menu),
          onPressed: onToggleExtended,
        ),
        if (isExtended)
          _CreateExpansionTile(onNavigateToCreate: onNavigateToCreate),
      ],
    );
  }
}

class _CreateExpansionTile extends StatelessWidget {
  final Function(BuildContext, Widget, String) onNavigateToCreate;

  const _CreateExpansionTile({required this.onNavigateToCreate});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 160,
        maxWidth: math.min(250, MediaQuery.of(context).size.width * 0.2),
      ),
      child: IntrinsicWidth(
        child: ExpansionTile(
          title: const Text("Create"),
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text("Folder"),
              onTap: () => onNavigateToCreate(context, const CreateFolderPage(), "Add Folder"),
            ),
            ListTile(
              leading: const Icon(Icons.add_link),
              title: const Text("Link"),
              onTap: () => onNavigateToCreate(context, const CreateLinkPage(), "Add Link"),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text("Document"),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Document creation coming soon!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
