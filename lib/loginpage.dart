import 'package:flutter/material.dart';
import 'package:inventaris_app/mysql_utils.dart';
import 'AdminHome.dart';
import 'PekerjaHome.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});
  

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  void loginUser() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Username dan Password harus diisi!';
      });
      return;
    }

    final conn = await MysqlUtils.getConnection();
    try {
      var result = await conn.query(
        'SELECT * FROM users WHERE username = ? AND password = ?',
        [usernameController.text, passwordController.text],
      );

      if (result.isNotEmpty) {
        var row = result.first;
        String role = row['role'];

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHome(role: 'admin',)),
          );
        } else if (role == 'pekerja') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PekerjaHome()),
          );
        }
      } else {
        setState(() {
          errorMessage = 'Username atau Password salah!';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      await conn.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Image.asset(
                'assets/images/login-page-banner.webp',
                height: 250
              ),
              const SizedBox(height: 100),
              SizedBox(
                width: double.infinity,
                child: const Text(
                  'Login',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 30, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: const Text(
                  'Silakan login untuk melanjutkan',
                  style: TextStyle(fontSize: 17, color: Colors.grey, fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  TextField(
                    controller: usernameController,
                    decoration:  InputDecoration(
                      labelText: 'Username', 

                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Login', style: TextStyle(fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w500,color: Colors.white)),
                    ),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
