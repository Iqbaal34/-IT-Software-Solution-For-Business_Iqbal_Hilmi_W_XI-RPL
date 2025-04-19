import 'package:flutter/material.dart';
import 'mysql_utils.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController kategoriController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  bool loading = false;
  String pesan = '';

  Future<void> tambahProduk() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      pesan = '';
    });

    try {
      final conn = await MysqlUtils.getConnection();
      await conn.query(
        'INSERT INTO products (namaproduk, kategori, harga, stok, image) VALUES (?, ?, ?, ?, ?)',
        [
          namaController.text,
          kategoriController.text,
          int.parse(hargaController.text),
          int.parse(stokController.text),
          imageController.text,
        ],
      );
      await conn.close();

      setState(() {
        pesan = 'Produk berhasil ditambahkan!';
        loading = false;
      });

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        pesan = 'Gagal menambahkan produk: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child:
                      imageController.text.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          )
                          : const Center(
                            child: Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 20),

              _buildInput(namaController, 'Nama Produk'),
              const SizedBox(height: 12),
              _buildInput(kategoriController, 'Kategori'),
              const SizedBox(height: 12),
              _buildInput(hargaController, 'Harga', isNumber: true),
              const SizedBox(height: 12),
              _buildInput(stokController, 'Stok', isNumber: true),
              const SizedBox(height: 12),
              _buildInput(imageController, 'URL Gambar'),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: loading ? null : tambahProduk,
                icon:
                    loading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(loading ? 'Menyimpan...' : 'Simpan Produk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (pesan.isNotEmpty)
                Text(
                  pesan,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        pesan.contains('berhasil') ? Colors.green : Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:
          (value) =>
              (value == null || value.isEmpty)
                  ? 'Field $label wajib diisi'
                  : null,
    );
  }
}
