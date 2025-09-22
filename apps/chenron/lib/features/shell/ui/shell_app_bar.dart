import 'package:flutter/material.dart';
import 'package:chenron/features/create/folder/pages/create_folder.dart';
import 'package:chenron/features/create/link/pages/create_link.dart';

class ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(BuildContext, Widget, String) onNavigateToCreate;

  const ShellAppBar({
    super.key,
    required this.onNavigateToCreate,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo/Brand section
          const _LogoSection(),
          
          // Spacer to push search to center
          const Spacer(),
          
          // Centered search bar
          const Expanded(
            flex: 2,
            child: _SearchBarSection(),
          ),
          
          // Spacer to balance the layout
          const Spacer(),
          
          // Right side actions
          _ActionsSection(onNavigateToCreate: onNavigateToCreate),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.apps,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'chenron',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBarSection extends StatelessWidget {
  const _SearchBarSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: SearchBar(
        hintText: "Search",
        leading: const Icon(
          Icons.search,
          color: Colors.grey,
          size: 20,
        ),
        backgroundColor: WidgetStatePropertyAll(
          Colors.grey[100],
        ),
        elevation: const WidgetStatePropertyAll(1),
        side: WidgetStatePropertyAll(
          BorderSide(color: Colors.grey[300]!),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        hintStyle: WidgetStatePropertyAll(
          TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}

class _ActionsSection extends StatelessWidget {
  final Function(BuildContext, Widget, String) onNavigateToCreate;

  const _ActionsSection({required this.onNavigateToCreate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Create dropdown button
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.add,
            color: Colors.grey,
            size: 20,
          ),
          tooltip: 'Create',
          onSelected: (String value) {
            switch (value) {
              case 'folder':
                onNavigateToCreate(context, CreateFolderPage(), 'Add Folder');
                break;
              case 'link':
                onNavigateToCreate(context, CreateLinkPage(), 'Add Link');
                break;
              case 'document':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Document creation coming soon!")),
                );
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'folder',
              child: ListTile(
                leading: Icon(Icons.create_new_folder_outlined),
                title: Text('Folder'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'link',
              child: ListTile(
                leading: Icon(Icons.add_link),
                title: Text('Link'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'document',
              child: ListTile(
                leading: Icon(Icons.article_outlined),
                title: Text('Document'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // User avatar
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}