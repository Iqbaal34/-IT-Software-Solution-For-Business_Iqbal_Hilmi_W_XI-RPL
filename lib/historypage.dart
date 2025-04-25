import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventaris_app/mysql_utils.dart';
import 'package:inventaris_app/templates/navbarwidget.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final conn = await MysqlUtils.getConnection();
    final result = await conn.query(
      'SELECT reports.jenis, products.namaproduk, supplier.namasupplier, '
      'reports.qty, reports.harga, reports.tanggal '
      'FROM reports '
      'JOIN products ON reports.idproduk = products.idproduk '
      'JOIN supplier ON reports.idsupplier = supplier.idsupplier '
      'ORDER BY reports.tanggal DESC'
    );

    List<Map<String, dynamic>> fetched = [];
    for (var row in result) {
      fetched.add({
        'type': row['jenis'],
        'product': row['namaproduk'],
        'supplier': row['namasupplier'],
        'qty': row['qty'],
        'harga': row['harga'],
        'tanggal': DateFormat('dd MMM yyyy - HH:mm').format(row['tanggal']),
      });
    }

    setState(() {
      history = fetched;
      isLoading = false;
    });

    await conn.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : history.isEmpty
                ? const Center(child: Text("Belum ada transaksi."))
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final isMasuk = item['type'] == 'pemasukan';
                      final badgeColor = isMasuk ? Colors.green : Colors.red;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isMasuk ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: badgeColor,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item['product'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item['type'].toUpperCase(),
                                    style: TextStyle(
                                      color: badgeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("Supplier: ${item['supplier']}"),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.inventory_2, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("Qty: ${item['qty']}"),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("Harga: Rp${item['harga']}"),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("Tanggal: ${item['tanggal']}"),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
