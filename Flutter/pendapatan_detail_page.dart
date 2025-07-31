import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PendapatanDetailPage extends StatelessWidget {
  final String bulan;
  PendapatanDetailPage({super.key, required this.bulan});

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<List<Map<String, dynamic>>> fetchPendapatan(String bulan) async {
    debugPrint("📡 Fetch pendapatan bulan (yyyy-MM): $bulan");
    final url =
        'http://192.168.182.125/simko_api/get_pendapatan.php?bulan=${Uri.encodeComponent(bulan)}';
    final response = await http.get(Uri.parse(url));

    debugPrint("📥 Response: ${response.statusCode}");

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      debugPrint("📦 Decoded JSON: $decoded");

      if (decoded['success'] == true && decoded['data'] is List) {
        return List<Map<String, dynamic>>.from(decoded['data']);
      } else {
        throw Exception('Data tidak ditemukan atau format salah');
      }
    } else {
      throw Exception('Gagal mengambil data dari server');
    }
  }

  @override
  Widget build(BuildContext context) {
    final readable = DateFormat(
      'MMMM yyyy',
      'en_US',
    ).format(DateTime.parse('$bulan-01'));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pendapatan - $readable',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 70, 95),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPendapatan(bulan),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('❌ Terjadi kesalahan: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('📭 Tidak ada data'));
          } else {
            return ListView(
              children:
                  snapshot.data!.map((item) {
                    final nama = item['nama'] ?? 'Tanpa Nama';
                    final tanggal = item['tanggal'] ?? '';
                    final jumlah = item['jumlah'];
                    final metode = item['metode'] ?? '';
                    final bukti = item['bukti_transfer'];
                    final formattedDate =
                        tanggal.isNotEmpty
                            ? DateFormat(
                              'd MMM yyyy',
                              'en_US',
                            ).format(DateTime.parse(tanggal))
                            : '-';

                    debugPrint(
                      "📄 Data item: nama=$nama, metode=$metode, bukti=$bukti",
                    );

                    return ListTile(
                      leading: CircleAvatar(child: Text(nama[0].toUpperCase())),
                      title: Text(nama),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formattedDate),
                          if (metode.toLowerCase() == 'transfer' &&
                              bukti != null &&
                              bukti.toString().isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                final imageUrl =
                                    'http://192.168.182.125/simko_api/$bukti';
                                debugPrint("🖼️ Menampilkan gambar: $imageUrl");

                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => Dialog(
                                        child: InteractiveViewer(
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              debugPrint(
                                                "❌ Gagal memuat gambar: $error",
                                              );
                                              return const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Text(
                                                  "Gagal memuat gambar bukti transfer",
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                );
                              },
                              child: const Text(
                                'Lihat Bukti Transfer',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing:
                          jumlah != null
                              ? Text(
                                formatRupiah.format(
                                  int.tryParse(jumlah.toString()) ?? 0,
                                ),
                              )
                              : const Text('Rp 0'),
                    );
                  }).toList(),
            );
          }
        },
      ),
    );
  }
}
