import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'pengeluaran_detail_page.dart';
import 'pendapatan_detail_page.dart';

class KeuanganPage extends StatelessWidget {
  const KeuanganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Manajemen Keuangan",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 10, 70, 95),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Color.fromARGB(200, 255, 255, 255),
            tabs: [
              Tab(
                child: Text(
                  'Pendapatan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Pengeluaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BulanListPage(jenis: 'pendapatan'),
            BulanListPage(jenis: 'pengeluaran'),
          ],
        ),
      ),
    );
  }
}

class BulanListPage extends StatelessWidget {
  final String jenis;
  const BulanListPage({super.key, required this.jenis});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<DateTime> bulanList = List.generate(12, (i) {
      return DateTime(now.year, i + 1); // Januari - Desember
    });

    return ListView.builder(
      itemCount: bulanList.length,
      itemBuilder: (context, index) {
        final dt = bulanList[index];
        final label = DateFormat('MMMM yyyy', 'en_US').format(dt); // July 2025
        final ym = DateFormat('yyyy-MM').format(dt); // 2025-07

        return ListTile(
          title: Text(
            label,
            style: TextStyle(
              color:
                  jenis == 'pendapatan'
                      ? Colors.teal[800]
                      : Colors.deepOrange[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            debugPrint("🔼 Navigasi ke ${jenis.toUpperCase()} bulan: $ym");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        jenis == 'pendapatan'
                            ? PendapatanDetailPage(bulan: ym)
                            : PengeluaranDetailPage(bulan: label),
              ),
            );
          },
        );
      },
    );
  }
}
