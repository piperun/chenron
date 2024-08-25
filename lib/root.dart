import 'package:chenron/folder/create/create_stepper.dart';
import 'package:chenron/home/homepage.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SideMenu(
          controller: sideMenu,
          style: SideMenuStyle(
            // showTooltip: false,
            displayMode: SideMenuDisplayMode.auto,
            showHamburger: true,
            hoverColor: Colors.blue[100],
            selectedHoverColor: Colors.blue[100],
            selectedColor: Colors.lightBlue,
            selectedTitleTextStyle: const TextStyle(color: Colors.white),
            selectedIconColor: Colors.white,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.all(Radius.circular(10)),
            // ),
            // backgroundColor: Colors.grey[200]
          ),
          items: [
            SideMenuItem(
              title: 'Dashboard',
              onTap: (index, _) {
                sideMenu.changePage(index);
              },
              icon: const Icon(Icons.home),
              badgeContent: const Text(
                '3',
                style: TextStyle(color: Colors.white),
              ),
              tooltipContent: "This is a tooltip for Dashboard item",
            ),
            SideMenuExpansionItem(
              title: "Expansion Item",
              icon: const Icon(Icons.kitchen),
              children: [
                SideMenuItem(
                  title: 'Expansion Item 1',
                  onTap: (index, _) {
                    sideMenu.changePage(index);
                  },
                  icon: const Icon(Icons.home),
                  badgeContent: const Text(
                    '3',
                    style: TextStyle(color: Colors.white),
                  ),
                  tooltipContent: "Expansion Item 1",
                ),
                SideMenuItem(
                  title: 'Expansion Item 2',
                  onTap: (index, _) {
                    sideMenu.changePage(index);
                  },
                  icon: const Icon(Icons.supervisor_account),
                )
              ],
            ),
          ],
        ),
        const VerticalDivider(
          width: 0,
        ),
        Flexible(
            child: PageView(
          controller: pageController,
          children: [
            Container(
              color: Colors.white,
              child: const Center(
                  child: HomePage(
                padding: 16,
              )),
            ),
            Container(
              color: Colors.black,
              child: const Center(child: CreateFolderStepper()),
            ),
            Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  'Expansion Item 1',
                  style: TextStyle(fontSize: 35),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  'Expansion Item 2',
                  style: TextStyle(fontSize: 35),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  'Files',
                  style: TextStyle(fontSize: 35),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  'Download',
                  style: TextStyle(fontSize: 35),
                ),
              ),
            ),
          ],
        ))
      ],
    );
  }
}
