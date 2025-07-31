import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Pengeluaran {
  int? id;
  String bulan;
  String keterangan;
  int jumlah;
  DateTime? tanggal;

  Pengeluaran({
    this.id,
    required this.bulan,
    required this.keterangan,
    required this.jumlah,
    this.tanggal,
  });

  factory Pengeluaran.fromJson(Map<String, dynamic> json) {
    return Pengeluaran(
      id: int.tryParse(json['id_pengeluaran'].toString()), // ⬅️ Fix di sini
      bulan: json['bulan'],
      keterangan: json['keterangan'],
      jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
      tanggal:
          json['tanggal'] != null ? DateTime.tryParse(json['tanggal']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengeluaran': id?.toString() ?? '',
      'bulan': bulan,
      'keterangan': keterangan,
      'jumlah': jumlah.toString(),
    };
  }
}

class PengeluaranDetailPage extends StatefulWidget {
  final String bulan;
  const PengeluaranDetailPage({super.key, required this.bulan});

  @override
  State<PengeluaranDetailPage> createState() => _PengeluaranDetailPageState();
}

class _PengeluaranDetailPageState extends State<PengeluaranDetailPage> {
  final String baseUrl = 'http://192.168.182.125/simko_api/pengeluaran_api.php';
  List<Pengeluaran> data = [];

  @override
  void initState() {
    super.initState();
    fetchPengeluaran();
  }

  Future<void> fetchPengeluaran() async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'get', 'bulan': widget.bulan}),
      );
      print('📥 FETCH RESPONSE BODY: ${res.body}'); // DEBUG FETCH
      final jsonRes = jsonDecode(res.body);
      if (jsonRes['success']) {
        setState(() {
          data =
              (jsonRes['data'] as List)
                  .map((e) => Pengeluaran.fromJson(e))
                  .toList();
        });
      }
    } catch (e) {
      print('Error fetch: $e');
    }
  }

  Future<void> simpanAtauEdit({Pengeluaran? existing}) async {
    final ketCtrl = TextEditingController(text: existing?.keterangan ?? '');
    final jmlCtrl = TextEditingController(
      text: existing?.jumlah.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(existing == null ? 'Tambah' : 'Edit'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ketCtrl,
                  decoration: const InputDecoration(labelText: 'Keterangan'),
                ),
                TextField(
                  controller: jmlCtrl,
                  decoration: const InputDecoration(labelText: 'Jumlah'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final body = {
                    'action': existing == null ? 'add' : 'edit',
                    'id_pengeluaran': existing?.id.toString() ?? '',
                    'bulan': widget.bulan,
                    'keterangan': ketCtrl.text.trim(),
                    'jumlah': int.tryParse(jmlCtrl.text.trim()) ?? 0,
                  };

                  try {
                    print('📤 SEND BODY: ${jsonEncode(body)}');
                    final res = await http.post(
                      Uri.parse(baseUrl),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(body),
                    );
                    print('✅ RESPONSE STATUS: ${res.statusCode}');
                    print('📥 RESPONSE BODY: ${res.body}');

                    final jsonRes = jsonDecode(res.body);
                    if (jsonRes['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Data berhasil disimpan')),
                      );
                      Navigator.pop(context);
                      fetchPengeluaran();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Gagal: ${jsonRes['message'] ?? 'Tidak diketahui'}',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    print('❌ ERROR SIMPAN: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terjadi kesalahan saat menyimpan'),
                      ),
                    );
                  }
                },

                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void hapusData(int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Hapus Data'),
            content: const Text('Yakin ingin menghapus data ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // tutup dialog dulu
                  try {
                    final res = await http.post(
                      Uri.parse(baseUrl),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'action': 'delete',
                        'id_pengeluaran': id,
                      }),
                    );

                    final jsonRes = jsonDecode(res.body);
                    if (jsonRes['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data berhasil dihapus')),
                      );
                      fetchPengeluaran(); // refresh data
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Gagal hapus: ${jsonRes['message'] ?? 'Tidak diketahui'}',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    print('DELETE ERROR: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terjadi kesalahan saat menghapus'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  // ... semua kode tetap sama hingga build()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengeluaran - ${widget.bulan}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 70, 95),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (_, i) {
          final item = data[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(item.keterangan),
              subtitle: Text('Rp ${item.jumlah}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => simpanAtauEdit(existing: item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => hapusData(item.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => simpanAtauEdit(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Pengeluaran',
      ),
    );
  }
}
