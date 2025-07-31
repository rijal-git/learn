import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_penghuni_page.dart';

class PenghuniDetailPage extends StatefulWidget {
  final String idPenghuni;

  const PenghuniDetailPage({super.key, required this.idPenghuni});

  @override
  State<PenghuniDetailPage> createState() => _PenghuniDetailPageState();
}

class _PenghuniDetailPageState extends State<PenghuniDetailPage> {
  Map<String, dynamic>? dataPenghuni;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetailPenghuni();
  }

  Future<void> fetchDetailPenghuni() async {
    final response = await http.get(
      Uri.parse(
        "http://192.168.182.125/simko_api/get_penghuni_detail.php?id=${widget.idPenghuni}",
      ),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        dataPenghuni = result;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat detail penghuni")),
      );
    }
  }

  Future<void> _hapusPenghuni() async {
    final response = await http.post(
      Uri.parse("http://192.168.182.125/simko_api/delete_penghuni.php"),
      body: {'id': widget.idPenghuni},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Penghuni berhasil dihapus.")),
      );
      Navigator.pop(context); // Kembali ke list
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menghapus penghuni")));
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus penghuni ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hapus'),
                onPressed: () {
                  Navigator.pop(context);
                  _hapusPenghuni();
                },
              ),
            ],
          ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Penghuni',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 70, 95),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : dataPenghuni == null
              ? const Center(child: Text("Data tidak ditemukan"))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...dataPenghuni!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                _capitalize(entry.key),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(child: Text(entry.value.toString())),
                          ],
                        ),
                      );
                    }).toList(),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => EditPenghuniPage(
                                      dataPenghuni: dataPenghuni!,
                                    ),
                              ),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          icon: const Icon(Icons.delete),
                          label: const Text("Hapus"),
                          onPressed: _showDeleteConfirmation,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
