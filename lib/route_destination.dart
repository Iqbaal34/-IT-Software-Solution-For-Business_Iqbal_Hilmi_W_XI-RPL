import 'package:flutter/material.dart';
import 'package:inventaris_app/AdminHome.dart';
import 'package:inventaris_app/settingpage.dart';
import 'inventorypage.dart';
import 'reportpage.dart';
import 'notifiers/navbar_notifiers.dart';
import 'PekerjaHome.dart';

class RouteDestination {
  static void GoToHome(BuildContext context, {required String role}) {
    navIndexNotifier.value = 0;

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHome()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PekerjaHome()),
      );
    }
  }

  static void GoToInventory(BuildContext context) {
    navIndexNotifier.value = 1;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Inventory()),
    );
  }

  static void GoToReport(BuildContext context) {
    navIndexNotifier.value = 2;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Report()),
    );
  }

  static void GoToSetting(BuildContext context) {
    navIndexNotifier.value = 3;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }
}
