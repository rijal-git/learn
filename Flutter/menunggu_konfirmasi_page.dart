import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MenungguKonfirmasiPage extends StatefulWidget {
  final String idPenghuni;
  final String ym;
  final String bulan;

  const MenungguKonfirmasiPage({
    super.key,
    required this.idPenghuni,
    required this.ym,
    required this.bulan,
  });

  @override
  State<MenungguKonfirmasiPage> createState() => _MenungguKonfirmasiPageState();
}

class _MenungguKonfirmasiPageState extends State<MenungguKonfirmasiPage> {
  late Timer _timer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    debugPrint(
      'MenungguKonfirmasiPage => idPenghuni: ${widget.idPenghuni}, ym: ${widget.ym}, bulan: ${widget.bulan}',
    );
    _startPolling();
  }

  void _startPolling() {
    _checkStatus();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    if (_checking) return;
    _checking = true;

    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.182.125/simko_api/get_status_per_bulan.php?id_penghuni=${widget.idPenghuni}&ym=${widget.ym}",
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];

        if (status == 'Lunas' && mounted) {
          _timer.cancel();
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      debugPrint("Error checking status: $e");
    } finally {
      _checking = false;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menunggu Konfirmasi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF014C5E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              Text(
                'Pembayaran bulan ${widget.bulan} sedang menunggu konfirmasi admin.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Silakan tunggu beberapa saat...',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF014C5E),
                  ),
                  child: const Text(
                    "Kembali",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
