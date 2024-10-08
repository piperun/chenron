import "package:chenron/database/database.dart";
import "package:chenron/ui/settings/settings_page.dart";
import "package:chenron/ui/folder/create/create_stepper.dart";
import "package:chenron/ui/folder/viewer/folder_viewer.dart";
import "package:chenron/ui/home/homepage.dart";
import "package:easy_sidemenu/easy_sidemenu.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final PageController pageController = PageController();
  final SideMenuController sideMenu = SideMenuController();

  @override
  void initState() {
    super.initState();
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomSideMenu(sideMenu: sideMenu),
        const VerticalDivider(width: 0),
        Flexible(child: CustomPageView(pageController: pageController)),
      ],
    );
  }
}

class CustomSideMenu extends StatelessWidget {
  final SideMenuController sideMenu;

  const CustomSideMenu({super.key, required this.sideMenu});

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      controller: sideMenu,
      style: SideMenuStyle(
        displayMode: SideMenuDisplayMode.auto,
        showHamburger: true,
        hoverColor: Colors.blue[100],
        selectedHoverColor: Colors.blue[100],
        selectedColor: Colors.lightBlue,
        selectedTitleTextStyle: const TextStyle(color: Colors.white),
        selectedIconColor: Colors.white,
      ),
      items: [
        SideMenuItem(
          title: "Dashboard",
          onTap: (index, _) => sideMenu.changePage(index),
          icon: const Icon(Icons.home),
          //badgeContent: const Text('3', style: TextStyle(color: Colors.white)),
          tooltipContent: "Dashboard",
        ),
        SideMenuItem(
          title: "Settings",
          onTap: (index, _) => sideMenu.changePage(index),
          icon: const Icon(Icons.settings),
        ),
        SideMenuExpansionItem(
          title: "Folder",
          icon: const Icon(Icons.folder),
          children: [
            SideMenuItem(
              title: "Create",
              onTap: (index, _) => sideMenu.changePage(index),
              icon: const Icon(Icons.create_new_folder),
              badgeContent:
                  const Text("3", style: TextStyle(color: Colors.white)),
              tooltipContent: "Create a new folder",
            ),
            SideMenuItem(
              title: "Viewer",
              onTap: (index, _) => sideMenu.changePage(index),
              icon: const Icon(Icons.view_list_outlined),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomPageView extends StatelessWidget {
  final PageController pageController;

  const CustomPageView({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    Provider.of<ConfigDatabase>(context, listen: false);
    return PageView(
      controller: pageController,
      children: const [
        PageViewItem(color: Colors.white, child: HomePage(padding: 16)),
        PageViewItem(color: Colors.white, child: SettingsPage()),
        PageViewItem(color: Colors.black, child: CreateFolderStepper()),
        PageViewItem(color: Colors.white, child: FolderViewSlug()),
        PageViewItem(
            color: Colors.white,
            child: Text("Expansion Item 2", style: TextStyle(fontSize: 35))),
        PageViewItem(
            color: Colors.white,
            child: Text("Files", style: TextStyle(fontSize: 35))),
        PageViewItem(
            color: Colors.white,
            child: Text("Download", style: TextStyle(fontSize: 35))),
      ],
    );
  }
}

class PageViewItem extends StatelessWidget {
  final Color color;
  final Widget child;

  const PageViewItem({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(child: child),
    );
  }
}
