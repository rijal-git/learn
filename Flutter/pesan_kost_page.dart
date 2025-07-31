// ======================= IMPORT =======================
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pembayaran_awal_page.dart'; // Ganti path sesuai struktur folder

// ===================== PESAN KOST PAGE =====================
class PesanKostPage extends StatefulWidget {
  final String idPenghuni;

  const PesanKostPage({Key? key, required this.idPenghuni}) : super(key: key);

  @override
  State<PesanKostPage> createState() => _PesanKostPageState();
}

class _PesanKostPageState extends State<PesanKostPage> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;
  List<dynamic> kostList = [];

  @override
  void initState() {
    super.initState();
    _fetchKostData();
  }

  // ===================== FETCH DATA =====================
  Future<void> _fetchKostData() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.182.125/simko_api/get_kost.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          kostList = json.decode(response.body);
        });
      } else {
        _showSnack('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _showSnack('Gagal mengambil data kost: $e');
    }
  }

  // =================== SHOW SNACKBAR ===================
  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ================== BUAT SEWA & LANJUT PEMBAYARAN ==================
  Future<void> _buatSewaDanKePembayaran() async {
    final kost = kostList[_currentIndex];
    final idKost = kost['id'];
    final kamar = kost['kamar'];

    final res = await http.post(
      Uri.parse('http://192.168.182.125/simko_api/add_sewa.php'),
      body: {'id_penghuni': widget.idPenghuni, 'id_kost': idKost.toString()},
    );

    final jsonRes = json.decode(res.body);
    if (jsonRes['success'] != true) {
      _showSnack('Gagal membuat sewa: ${jsonRes['msg'] ?? ''}');
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                PembayaranAwalPage(kamar: kamar, idPenghuni: widget.idPenghuni),
      ),
    );
  }

  // ================= PAGE NAVIGATION =================
  void _goToPreviousPage() {
    if (_currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (_currentIndex < kostList.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ===================== BUILD =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12657A),
      body: SafeArea(
        child:
            kostList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset("assets/simko_logo.png", height: 60),
                    const SizedBox(height: 10),
                    const Text(
                      "PESAN KAMAR",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ================= KOST CARD SLIDER =================
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView.builder(
                            controller: _controller,
                            itemCount: kostList.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final kost = kostList[index];
                              return _buildKostCard(kost);
                            },
                          ),
                          Positioned(
                            left: 10,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                              onPressed: _goToPreviousPage,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                              onPressed: _goToNextPage,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================= BUTTON PESAN =================
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _buatSewaDanKePembayaran,
                        icon: const Icon(Icons.payment),
                        label: const Text(
                          "PESAN SEKARANG",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            243,
                            242,
                            242,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  // =============== KOST CARD WIDGET =================
  Widget _buildKostCard(Map<String, dynamic> kost) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Image.network(
                kost['gambar'], // Sudah full URL dari get_kost.php
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.error, size: 100),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.aspect_ratio, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          kost['ukuran'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            kost['status'] ?? 'Kosong',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Fasilitas",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(kost['fasilitas'] ?? '-'),
                    const SizedBox(height: 10),
                    const Text(
                      "Harga / Bulan (Rp)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Rp. ${kost['harga']}",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
