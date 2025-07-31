import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'form_pindah_kamar.dart';

class DataSewaPage extends StatefulWidget {
  final int idPenghuni;
  const DataSewaPage({super.key, required this.idPenghuni});

  @override
  State<DataSewaPage> createState() => _DataSewaPageState();
}

class _DataSewaPageState extends State<DataSewaPage> {
  Map<String, dynamic>? sewa;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final url =
        'http://192.168.182.125/simko_api/get_data_sewa.php?id_penghuni=${widget.idPenghuni}';
    print("🔍 GET: $url");
    final res = await http.get(Uri.parse(url));
    print("📥 RESPON STATUS: ${res.statusCode}");
    print("📥 RESPON BODY: ${res.body}");
    if (res.statusCode == 200) {
      final d = jsonDecode(res.body);
      setState(() => sewa = d.isNotEmpty ? d[0] : null);
    }
  }

  Future<void> _berhenti() async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Anda yakin ingin berhenti?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ya'),
              ),
            ],
          ),
    );
    if (ok != true) return;

    final res = await http.post(
      Uri.parse('http://192.168.182.125/simko_api/berhenti_sewa.php'),
      body: {
        'id_penghuni': widget.idPenghuni.toString(),
        'alasan': 'Berhenti oleh penghuni',
      },
    );
    print("🧾 Berhenti Respon: ${res.body}");

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sewa == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Data Sewa'),
          backgroundColor: const Color.fromARGB(255, 10, 70, 95),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Belum ada data sewa.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Sewa'),
        backgroundColor: const Color.fromARGB(255, 10, 70, 95),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                sewa!['gambar'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 80),
              ),
            ),
            const SizedBox(height: 16),
            _info('Nomor Kamar', sewa!['kamar']),
            _info('Ukuran', sewa!['ukuran']),
            _info('Fasilitas', sewa!['fasilitas']),
            _info('Harga / bulan', 'Rp ${sewa!['harga']}'),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => FormPindahKamarPage(
                                idPenghuni: widget.idPenghuni,
                              ),
                        ),
                      ),
                  child: const Text('Pindah'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _berhenti,
                  child: const Text('Berhenti'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text(value),
      ],
    ),
  );
}
