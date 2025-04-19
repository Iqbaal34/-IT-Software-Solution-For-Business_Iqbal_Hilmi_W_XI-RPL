import 'package:flutter/material.dart';
import 'package:inventaris_app/mysql_utils.dart';
import 'package:inventaris_app/templates/navbarwidget.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final conn = await MysqlUtils.getConnection();
    final result = await conn.query(
      'SELECT reports.jenis, products.namaproduk, supplier.namasupplier, reports.qty, reports.harga, reports.tanggal '
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
        'tanggal': row['tanggal'].toString(),
      });
    }

    setState(() {
      reports = fetched;
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
          'Reports',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Riwayat Pemasukan & Pengeluaran Produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final r = reports[index];
                        final isMasuk = r['type'] == 'pemasukan';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isMasuk ? Icons.download : Icons.upload,
                                color: isMasuk ? Colors.green : Colors.red,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${r['product']} (${r['type']})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Supplier: ${r['supplier']}'),
                                    Text('Jumlah: ${r['qty']}'),
                                    Text('Harga: Rp${r['harga']}'),
                                    Text(
                                      'Tanggal: ${r['tanggal']}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
