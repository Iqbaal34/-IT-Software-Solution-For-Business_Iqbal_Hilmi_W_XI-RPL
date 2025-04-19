import 'package:flutter/material.dart';
import 'package:inventaris_app/mysql_utils.dart';
import 'package:inventaris_app/templates/navbarwidget.dart';
import 'package:mysql1/mysql1.dart';


class PekerjaHome extends StatelessWidget {
  const PekerjaHome({super.key});

  @override
  Widget build(BuildContext context) {
    selectAllProducts().then((results) {
      for (var row in results) {
        print('Product ID: ${row[0]}, Product name: ${row[1]} .....');
      }
    });
    

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'CekStok',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(
                    "60",
                    "Out of stock",
                    Icons.inventory_2_rounded,
                  ),
                  _buildStatCard("360", "Low stock", Icons.trending_down),
                  _buildStatCard("360", "Total Items", Icons.widgets),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Recent Documents",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("View All", style: TextStyle(color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: [
                    _buildRecentItem(
                      "Coca Cola",
                      "Silvia Thornton",
                      "8:30 AM",
                      "https://img.freepik.com/free-photo/cola-can_144627-19565.jpg",
                      true,
                    ),
                    _buildRecentItem(
                      "Doritos",
                      "Laura Kennedy",
                      "10:40 AM",
                      "https://img.freepik.com/free-photo/crispy-potato-chips-white-bowl-isolated-white-background_1150-24720.jpg",
                      false,
                    ),
                    _buildRecentItem(
                      "Lass",
                      "Carmen Dominguez",
                      "12:45 PM",
                      "https://img.freepik.com/free-photo/packaging-foil-bag-isolated_1101-110.jpg",
                      true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavbarWidget()
    );
  }

  Future<Results> selectAllProducts() async {
    final conn = await MysqlUtils.getConnection();
    final result = await conn.query(
      'SELECT id, name, price FROM products'
    );
    await conn.close();
    return result;
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
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}