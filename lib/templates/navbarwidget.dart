import 'package:flutter/material.dart';
import 'package:inventaris_app/notifiers/navbar_notifiers.dart';
import 'package:inventaris_app/route_destination.dart';

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({super.key});

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: navIndexNotifier.value,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: "Inventory",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
      ],
      onTap: (index) {
        if (index == 0) {
          RouteDestination.GoToHome(context, role: 'admin');
        }
        else if (index == 1) {
          RouteDestination.GoToInventory(context);
        }
        else if(index == 2) {
          RouteDestination.GoToReport(context);
        }
        else {
          RouteDestination.GoToSetting(context);
        }
      },
    );
  }
}
