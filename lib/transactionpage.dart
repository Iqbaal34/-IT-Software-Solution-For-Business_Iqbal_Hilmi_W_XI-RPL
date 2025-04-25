import 'package:flutter/material.dart';
import 'package:inventaris_app/mysql_utils.dart';
import 'package:inventaris_app/templates/navbarwidget.dart';
import 'package:mysql1/mysql1.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _ReportState();
}

class _ReportState extends State<TransactionPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> suppliers = [];

  String? selectedProduct;
  String? selectedSupplier;
  String transactionType = 'pemasukan';
  final qtyController = TextEditingController();
  final hargaController = TextEditingController();
  bool isLoading = false;

  @override
  final hargaSatuanController = TextEditingController();
  void initState() {
    super.initState();
    fetchData();
    qtyController.addListener(updateHargaTotal);
    hargaSatuanController.addListener(updateHargaTotal);
  }

  @override
  void dispose() {
    qtyController.dispose();
    hargaController.dispose();
    hargaSatuanController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    final conn = await MysqlUtils.getConnection();
    final prodResult = await conn.query(
      'SELECT idproduk, namaproduk FROM products',
    );
    final supResult = await conn.query(
      'SELECT idsupplier, namasupplier FROM supplier',
    );

    setState(() {
      products =
          prodResult
              .map((row) => {'id': row['idproduk'], 'name': row['namaproduk']})
              .toList();
      suppliers =
          supResult
              .map(
                (row) => {'id': row['idsupplier'], 'name': row['namasupplier']},
              )
              .toList();
    });

    await conn.close();
  }

  Future<void> createTransaction() async {
    if (selectedProduct == null ||
        selectedSupplier == null ||
        qtyController.text.isEmpty ||
        hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data terlebih dahulu.')),
      );
      return;
    }

    final qty = int.tryParse(qtyController.text) ?? 0;
    final harga =
        (int.tryParse(qtyController.text) ?? 0) *
        (int.tryParse(hargaSatuanController.text) ?? 0);

    setState(() => isLoading = true);

    final conn = await MysqlUtils.getConnection();

    // Simpan laporan
    await conn.query(
      'INSERT INTO reports (jenis, idproduk, idsupplier, qty, harga, tanggal) VALUES (?, ?, ?, ?, ?, NOW())',
      [transactionType, selectedProduct, selectedSupplier, qty, harga],
    );

    // Update stok produk
    if (transactionType == 'pemasukan') {
      await conn.query(
        'UPDATE products SET stok = stok + ? WHERE idproduk = ?',
        [qty, selectedProduct],
      );
    } else {
      await conn.query(
        'UPDATE products SET stok = GREATEST(stok - ?, 0) WHERE idproduk = ?',
        [qty, selectedProduct],
      );
    }

    await conn.close();
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil dicatat.')),
    );

    setState(() {
      selectedProduct = null;
      selectedSupplier = null;
      qtyController.clear();
      hargaController.clear();
    });
  }

  void updateHargaTotal() {
    final qty = int.tryParse(qtyController.text) ?? 0;
    final hargaSatuan = int.tryParse(hargaSatuanController.text) ?? 0;
    final total = qty * hargaSatuan;
    hargaController.text = total.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Buat Transaksi',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Produk', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: selectedProduct,
                  hint: const Text('Pilih Produk'),
                  items: products.map((product) {
                    return DropdownMenuItem(
                      value: product['id'].toString(),
                      child: Text(product['name']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedProduct = value),
                ),
                const SizedBox(height: 16),

                const Text('Pilih Supplier', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: selectedSupplier,
                  hint: const Text('Pilih Supplier'),
                  items: suppliers.map((supplier) {
                    return DropdownMenuItem(
                      value: supplier['id'].toString(),
                      child: Text(supplier['name']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedSupplier = value),
                ),
                const SizedBox(height: 16),

                const Text('Jumlah Stok', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Contoh: 10',
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Harga Satuan', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: hargaSatuanController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Contoh: 5000',
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Harga Total', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: hargaController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFFF0F0F0),
                    hintText: 'Akan terisi otomatis',
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Jenis Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Radio(
                      value: 'pemasukan',
                      groupValue: transactionType,
                      onChanged: (value) => setState(() => transactionType = value.toString()),
                    ),
                    const Text('Pemasukan'),
                    Radio(
                      value: 'pengeluaran',
                      groupValue: transactionType,
                      onChanged: (value) => setState(() => transactionType = value.toString()),
                    ),
                    const Text('Pengeluaran'),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: createTransaction,
                    icon: const Icon(Icons.save, color: Colors.white,),
                    label: Text('Simpan Transaksi', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
    ),
       bottomNavigationBar: const NavbarWidget(),
    );
    
  }
}
