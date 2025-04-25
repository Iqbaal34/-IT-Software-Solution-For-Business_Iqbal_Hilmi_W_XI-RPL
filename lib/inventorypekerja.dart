import 'package:flutter/material.dart';
import 'package:inventaris_app/mysql_utils.dart';
import 'package:inventaris_app/templates/navbarwidget.dart';
import 'addproductpage.dart';

class InventoryPekerja extends StatefulWidget {
  const InventoryPekerja({super.key});

  @override
  State<InventoryPekerja> createState() => _InventoryPekerjaState();
}

class _InventoryPekerjaState extends State<InventoryPekerja> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;
  String selectedFilter = 'Semua';
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final conn = await MysqlUtils.getConnection();
    final result = await conn.query('SELECT * FROM products');
    await conn.close();

    List<Map<String, dynamic>> fetched = [];
    for (var row in result) {
      fetched.add({
        'id': row['idproduk'],
        'name': row['namaproduk'],
        'category': row['kategori'],
        'stock': row['stok'],
        'price': row['harga'],
        'image': row['image'],
      });
    }

    setState(() {
      products = fetched;
      applyFilter();
      isLoading = false;
    });
  }

  void applyFilter() {
    List<Map<String, dynamic>> temp = [...products];

    if (selectedFilter == 'Harga Termurah') {
      temp.sort((a, b) => a['price'].compareTo(b['price']));
    } else if (selectedFilter == 'Harga Termahal') {
      temp.sort((a, b) => b['price'].compareTo(a['price']));
    } else if (selectedFilter == 'Stok Terendah') {
      temp.sort((a, b) => a['stock'].compareTo(b['stock']));
    } else if (selectedFilter.startsWith('Kategori: ')) {
      String kategori = selectedFilter.replaceFirst('Kategori: ', '');
      temp = temp.where((p) => p['category'] == kategori).toList();
    }

    // filter berdasarkan pencarian
    if (searchCtrl.text.isNotEmpty) {
      temp = temp.where((p) => p['name']
          .toString()
          .toLowerCase()
          .contains(searchCtrl.text.toLowerCase())).toList();
    }

    setState(() {
      filteredProducts = temp;
    });
  }

  void deleteProduct(int id) async {
    final conn = await MysqlUtils.getConnection();
    await conn.query('DELETE FROM products WHERE idproduk = ?', [id]);
    await conn.close();
    fetchProducts(); // refresh data
  }

  List<String> getAllCategories() {
    final categories = products.map((p) => p['category'].toString()).toSet().toList();
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Inventory Produk', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProduct()),
          ).then((_) => fetchProducts()); // refresh setelah tambah
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Search
                  TextField(
                    controller: searchCtrl,
                    onChanged: (_) => applyFilter(),
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedFilter,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                      const DropdownMenuItem(value: 'Harga Termurah', child: Text('Harga Termurah')),
                      const DropdownMenuItem(value: 'Harga Termahal', child: Text('Harga Termahal')),
                      const DropdownMenuItem(value: 'Stok Terendah', child: Text('Stok Terendah')),
                      ...getAllCategories()
                          .map((cat) => DropdownMenuItem(
                                value: 'Kategori: $cat',
                                child: Text('Kategori: $cat'),
                              ))
                          ,
                    ],
                    onChanged: (val) {
                      selectedFilter = val!;
                      applyFilter();
                    },
                  ),

                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final p = filteredProducts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  p['image'].toString() ?? 'https://via.placeholder.com/50',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text("(${p['category']})"),
                                    const SizedBox(height: 4),
                                    Text('${p['stock']} in Stock'),
                                  ],
                                ),
                              ),

                              // Harga dan aksi
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Rp${p['price']}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
