import 'package:flutter/material.dart';
import 'package:inventaris_app/mysql_utils.dart';
import 'package:mysql1/mysql1.dart';

class SupplierManagementPage extends StatefulWidget {
  const SupplierManagementPage({super.key});

  @override
  State<SupplierManagementPage> createState() => _SupplierManagementPageState();
}

class _SupplierManagementPageState extends State<SupplierManagementPage> {
  List<Map<String, dynamic>> suppliers = [];
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    final conn = await MysqlUtils.getConnection();
    final result = await conn.query('SELECT * FROM supplier');

    suppliers =
        result.map((row) {
          return {
            'id': row['idsupplier'],
            'name': row['namasupplier'],
            'contact': row['contact'],
            'address': row['adress'],
          };
        }).toList();

    setState(() => isLoading = false);
    await conn.close();
  }

  Future<void> addOrUpdateSupplier({int? id}) async {
    final name = nameController.text.trim();
    final contact = contactController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty || contact.isEmpty || address.isEmpty) return;

    final conn = await MysqlUtils.getConnection();

    if (id == null) {
      await conn.query(
        'INSERT INTO supplier (namasupplier, contact, adress) VALUES (?, ?, ?)',
        [name, contact, address],
      );
    } else {
      await conn.query(
        'UPDATE supplier SET namasupplier = ?, contact = ?, adress = ? WHERE idsupplier = ?',
        [name, contact, address, id],
      );
    }

    nameController.clear();
    contactController.clear();
    addressController.clear();

    await fetchSuppliers();
    Navigator.pop(context);
  }

  Future<void> deleteSupplier(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menghapus supplier ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    final conn = await MysqlUtils.getConnection();
    await conn.query('DELETE FROM supplier WHERE idsupplier = ?', [id]);
    await fetchSuppliers();
  }

  void showForm({Map<String, dynamic>? supplier}) {
    if (supplier != null) {
      nameController.text = supplier['name'];
      contactController.text = supplier['contact'];
      addressController.text = supplier['address'];
    } else {
      nameController.clear();
      contactController.clear();
      addressController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: MediaQuery.of(
            context,
          ).viewInsets.add(const EdgeInsets.all(20)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  supplier == null ? 'Tambah Supplier' : 'Edit Supplier',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Supplier',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Kontak',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => addOrUpdateSupplier(id: supplier?['id']),
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Management'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: suppliers.length,
                itemBuilder: (_, index) {
                  final s = suppliers[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        s['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('📞 ${s['contact']}'),
                          Text('📍 ${s['address']}'),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showForm(supplier: s),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteSupplier(s['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
