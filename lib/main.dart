import 'package:flutter/material.dart';
import 'package:inventaris_app/loginpage.dart';
import 'package:inventaris_app/mysql_utils.dart';

import 'AdminHome.dart';
import 'PekerjaHome.dart';
import 'settingpage.dart';

void main() {
  MysqlUtils.initConnection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Loginpage(),
        '/adminhome': (context) => const AdminHome(role: 'admin',),
        '/pekerjahome': (context) => const PekerjaHome(),
        '/settings': (context) => const SettingsPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.light,
        ),
      ),
      home: Loginpage(),
    );
  }
}
