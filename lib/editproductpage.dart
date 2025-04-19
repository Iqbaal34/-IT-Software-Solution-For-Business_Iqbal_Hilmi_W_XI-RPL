import 'package:flutter/material.dart';
import 'package:inventaris_app/mysql_utils.dart';

class EditProduct extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditProduct({super.key, required this.product});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController categoryCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController imageCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.product['name'].toString());
    categoryCtrl = TextEditingController(text: widget.product['category'].toString());
    stockCtrl = TextEditingController(text: widget.product['stock'].toString());
    priceCtrl = TextEditingController(text: widget.product['price'].toString());
    imageCtrl = TextEditingController(text: widget.product['image'].toString());
  }

  Future<void> updateProduct() async {
    final conn = await MysqlUtils.getConnection();
    await conn.query(
      'UPDATE products SET namaproduk = ?, kategori = ?, stok = ?, harga = ?, image = ? WHERE idproduk = ?',
      [
        nameCtrl.text,
        categoryCtrl.text,
        int.tryParse(stockCtrl.text),
        int.tryParse(priceCtrl.text),
        imageCtrl.text,
        widget.product['id'],
      ],
    );
    await conn.close();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Edit Produk'),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageCtrl.text.isNotEmpty
                        ? imageCtrl.text
                        : 'https://via.placeholder.com/150',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildInput(nameCtrl, 'Nama Produk'),
              const SizedBox(height: 12),
              _buildInput(categoryCtrl, 'Kategori'),
              const SizedBox(height: 12),
              _buildInput(stockCtrl, 'Stok', isNumber: true),
              const SizedBox(height: 12),
              _buildInput(priceCtrl, 'Harga', isNumber: true),
              const SizedBox(height: 12),
              _buildInput(imageCtrl, 'Link Gambar'),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateProduct();
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
    );
  }
}
