import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'penghuni_detail_page.dart';

class PenghuniPage extends StatefulWidget {
  const PenghuniPage({super.key});

  @override
  State<PenghuniPage> createState() => _PenghuniPageState();
}

class _PenghuniPageState extends State<PenghuniPage> {
  List<dynamic> _penghuniList = [];
  bool _isLoading = true;

  int jumlahAktif = 0;
  int jumlahBelumAktif = 0;

  @override
  void initState() {
    super.initState();
    _fetchPenghuni();
  }

  Future<void> _fetchPenghuni() async {
    final url = Uri.parse('http://192.168.182.125/simko_api/get_penghuni.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          setState(() {
            _penghuniList = data;
            jumlahAktif =
                data.where((item) => item['aktif'].toString() == '1').length;
            jumlahBelumAktif =
                data.where((item) => item['aktif'].toString() != '1').length;
            _isLoading = false;
          });
        } else {
          _showError('Format data tidak sesuai');
        }
      } else {
        _showError('Gagal memuat data penghuni');
      }
    } catch (e) {
      _showError('Terjadi kesalahan koneksi');
    }
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 10, 70, 95),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Text(
              'Manajemen Penghuni',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🔴 $jumlahBelumAktif',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const Spacer(),
            Text(
              'Aktif: $jumlahAktif',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                itemCount: _penghuniList.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final penghuni = _penghuniList[index];
                  final nama = penghuni['nama'] ?? '';
                  final email = penghuni['email'] ?? '';
                  final aktif = penghuni['aktif'].toString() == '1';

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            nama,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              aktif ? 'Aktif' : 'Belum Aktif',
                              style: TextStyle(
                                color: aktif ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Text(email),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => PenghuniDetailPage(
                                idPenghuni: penghuni['id'].toString(),
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
