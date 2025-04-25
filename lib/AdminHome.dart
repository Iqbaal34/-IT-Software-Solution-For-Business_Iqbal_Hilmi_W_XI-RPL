import 'package:flutter/material.dart';
import 'package:inventaris_app/inventoryadmin.dart';
import 'package:inventaris_app/route_destination.dart';
import 'package:inventaris_app/settingpage.dart';
import 'inventorypekerja.dart';
import 'mysql_utils.dart';
import 'templates/navbarwidget.dart';

class AdminHome extends StatefulWidget {
  final String role; // TERIMA role
  const AdminHome({super.key, required this.role});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  int lowStockCount = 0;
  int highStockCount = 0;
  final TextEditingController searchCtrl = TextEditingController();
  List<Map<String, dynamic>> allProducts = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final conn = await MysqlUtils.getConnection();
    final result = await conn.query('SELECT * FROM products');

    List<Map<String, dynamic>> fetched = [];
    
    for (var row in result) {
      int stock = row['stok'];
      if (stock < 15) lowStockCount++;
      if (stock > 15) highStockCount++;

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
      allProducts = fetched;
      isLoading = false;
    });

    await conn.close();
  }

  void applyFilter() {
    final query = searchCtrl.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        products = allProducts.where((p) {
          return p['name'].toString().toLowerCase().contains(query);
        }).toList();
      } else {
        products = allProducts;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'CekStok',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      RouteDestination.GoToSetting(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Search Bar
              TextField(
                controller: searchCtrl,
                onChanged: (_) => applyFilter(),
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Statistik Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(highStockCount.toString(), "High stock", Icons.trending_up),
                  _buildStatCard(lowStockCount.toString(), "Low stock", Icons.trending_down),
                  _buildStatCard(products.length.toString(), "Total Items", Icons.widgets),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Documents",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      RouteDestination.GoToInventory(context, role: widget.role); // pakai role dari widget
                    },
                    child: const Text(
                      "View All",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- Daftar Produk dari Database
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final p = products[index];
                          final int stock = p['stock'] ?? 0;
                          final bool isUp = stock > 15;

                          return _buildRecentItem(
                            p['name'].toString(),
                            p['category'].toString(),
                            "Stok: $stock",
                            p['image'].toString().isNotEmpty
                                ? p['image'].toString()
                                : 'https://via.placeholder.com/50',
                            isUp,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentItem(
    String title,
    String user,
    String time,
    String imgUrl,
    bool isUp,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imgUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(user, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                isUp ? Icons.trending_up : Icons.trending_down,
                color: isUp ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
