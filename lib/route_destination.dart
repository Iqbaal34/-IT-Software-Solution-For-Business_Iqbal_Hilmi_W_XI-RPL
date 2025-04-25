import 'package:flutter/material.dart';
import 'package:inventaris_app/AdminHome.dart';
import 'package:inventaris_app/settingpage.dart';
import 'inventoryadmin.dart';
import 'transactionpage.dart';
import 'notifiers/navbar_notifiers.dart';
import 'PekerjaHome.dart';
import 'loginpage.dart';
import 'inventorypekerja.dart';

class RouteDestination {
  static void GoToHome(BuildContext context, {required String role}) {
    navIndexNotifier.value = 0;

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHome(role: 'admin',)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PekerjaHome()),
      );
    }
  }

  static void GoToInventory(BuildContext context, {required String role}) {
    navIndexNotifier.value = 1;

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InventoryAdmin()),
      );
    } 
    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InventoryPekerja()),
      );
    }
  }

  static void GoToReport(BuildContext context) {
    navIndexNotifier.value = 2;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TransactionPage()),
    );
  }

  static void GoToSetting(BuildContext context) {
    navIndexNotifier.value = 3;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }
  static void GoToLoginPage(BuildContext context) {
    navIndexNotifier.value = 0;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Loginpage()),
    );
  }
}
