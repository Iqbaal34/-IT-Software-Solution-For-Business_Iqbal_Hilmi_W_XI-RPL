import 'package:flutter/material.dart';
import 'package:inventaris_app/mysql_utils.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final conn = await MysqlUtils.getConnection();
    final results = await conn.query('SELECT * FROM users');
    List<Map<String, dynamic>> temp = [];

    for (var row in results) {
      temp.add({
        'iduser': row['iduser'],
        'username': row['username'],
        'password': row['password'],
        'role': row['role'],
      });
    }

    setState(() {
      users = temp;
      isLoading = false;
    });
    await conn.close();
  }

  void deleteUser(int iduser) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah kamu yakin ingin menghapus akun ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final conn = await MysqlUtils.getConnection();
      await conn.query('DELETE FROM users WHERE iduser = ?', [iduser]);
      await conn.close();
      fetchUsers();
    }
  }

  void showEditDialog(Map<String, dynamic> user) {
    final usernameController = TextEditingController(text: user['username']);
    final passwordController = TextEditingController(text: user['password']);
    String selectedRole = user['role'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Akun'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                DropdownButtonFormField(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'pekerja', child: Text('Pekerja')),
                  ],
                  onChanged: (value) => selectedRole = value!,
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final conn = await MysqlUtils.getConnection();
                  await conn.query(
                    'UPDATE users SET username = ?, password = ?, role = ? WHERE iduser = ?',
                    [
                      usernameController.text,
                      passwordController.text,
                      selectedRole,
                      user['iduser'],
                    ],
                  );
                  await conn.close();
                  Navigator.pop(context);
                  fetchUsers();
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void showAddUserDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'pekerja';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tambah Akun'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                DropdownButtonFormField(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'pekerja', child: Text('Pekerja')),
                  ],
                  onChanged: (value) => selectedRole = value!,
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final conn = await MysqlUtils.getConnection();
                  await conn.query(
                    'INSERT INTO users (username, password, role) VALUES (?, ?, ?)',
                    [
                      usernameController.text,
                      passwordController.text,
                      selectedRole,
                    ],
                  );
                  await conn.close();
                  Navigator.pop(context);
                  fetchUsers();
                },
                child: const Text('Tambah'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Akun'),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              user['role'] == 'admin'
                                  ? Colors.orangeAccent
                                  : Colors.blueAccent,
                          child: Icon(
                            user['role'] == 'admin'
                                ? Icons.person
                                : Icons.people,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          user['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Role: ${user['role']}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => showEditDialog(user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteUser(user['iduser']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddUserDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Akun'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
