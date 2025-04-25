import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:inventaris_app/mysql_utils.dart';
import 'package:inventaris_app/templates/navbarwidget.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  Map<String, double> dailySales = {};
  Map<String, double> weeklySales = {};
  Map<String, double> monthlySales = {};
  double pemasukanTotal = 0;
  double pengeluaranTotal = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    final conn = await MysqlUtils.getConnection();

    final dailyResult = await conn.query('''
      SELECT DATE(tanggal) as date, SUM(harga) as total
      FROM reports
      WHERE jenis = 'pemasukan'
        AND tanggal >= CURDATE() - INTERVAL 7 DAY
      GROUP BY DATE(tanggal)
    ''');

    final weeklyResult = await conn.query('''
      SELECT YEARWEEK(tanggal, 1) as week, SUM(harga) as total
      FROM reports
      WHERE jenis = 'pemasukan'
        AND tanggal >= CURDATE() - INTERVAL 1 MONTH
      GROUP BY YEARWEEK(tanggal, 1)
    ''');

    final monthlyResult = await conn.query('''
      SELECT DATE_FORMAT(tanggal, '%Y-%m') as month, SUM(harga) as total
      FROM reports
      WHERE jenis = 'pemasukan'
        AND tanggal >= CURDATE() - INTERVAL 6 MONTH
      GROUP BY DATE_FORMAT(tanggal, '%Y-%m')
    ''');

    final cashflow = await conn.query('''
      SELECT jenis, SUM(harga) as total
      FROM reports
      WHERE tanggal >= CURDATE() - INTERVAL 1 MONTH
      GROUP BY jenis
    ''');

    Map<String, double> daily = {};
    Map<String, double> weekly = {};
    Map<String, double> monthly = {};
    double pemasukan = 0;
    double pengeluaran = 0;

    for (var row in dailyResult) {
      daily[row['date'].toString()] = row['total']?.toDouble() ?? 0;
    }

    for (var row in weeklyResult) {
      weekly[row['week'].toString()] = row['total']?.toDouble() ?? 0;
    }

    for (var row in monthlyResult) {
      monthly[row['month'].toString()] = row['total']?.toDouble() ?? 0;
    }

    for (var row in cashflow) {
      if (row['jenis'] == 'pemasukan') {
        pemasukan = row['total']?.toDouble() ?? 0;
      } else {
        pengeluaran = row['total']?.toDouble() ?? 0;
      }
    }

    setState(() {
      dailySales = daily;
      weeklySales = weekly;
      monthlySales = monthly;
      pemasukanTotal = pemasukan;
      pengeluaranTotal = pengeluaran;
      isLoading = false;
    });

    await conn.close();
  }

  Widget buildLineChart(String title, Map<String, double> data) {
    final spots = data.entries.toList().asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < data.keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              data.keys
                                  .elementAt(index)
                                  .substring(data.keys.elementAt(index).length - 2),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5000,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xff23b6e6), Color(0xff02d39a)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xff23b6e6).withOpacity(0.3),
                          const Color(0xff02d39a).withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Analitik'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLineChart('Penjualan Harian', dailySales),
                  buildLineChart('Penjualan Mingguan', weeklySales),
                  buildLineChart('Penjualan Bulanan', monthlySales),
                  const Text(
                    'Cashflow (30 Hari Terakhir)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text('Pemasukan Modal'),
                              const SizedBox(height: 4),
                              Text('Rp${pengeluaranTotal.toStringAsFixed(0)}'),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text('Pengeluaran Modal'),
                              const SizedBox(height: 4),
                              Text('Rp${pemasukanTotal.toStringAsFixed(0)}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
