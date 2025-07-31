import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'pembayaran_service.dart';

class PembayaranAwalPage extends StatefulWidget {
  final String kamar;
  final String idPenghuni;

  const PembayaranAwalPage({
    required this.kamar,
    required this.idPenghuni,
    Key? key,
  }) : super(key: key);

  @override
  _PembayaranAwalPageState createState() => _PembayaranAwalPageState();
}

class _PembayaranAwalPageState extends State<PembayaranAwalPage> {
  String metode = 'Cash';
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  Future<void> _submitPembayaran() async {
    if (_nominalController.text.isEmpty) {
      _showSnackbar("Nominal harus diisi.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final now = DateTime.now();
      final bulan = DateFormat('MMMM', 'en_US').format(now);
      final bulanYM = DateFormat('yyyy-MM').format(now);

      final response = await http.post(
        Uri.parse("http://192.168.182.125/simko_api/add_pembayaran.php"),
        body: {
          "id_penghuni": widget.idPenghuni,
          "metode": metode,
          "nominal": _nominalController.text,
          "catatan": _catatanController.text,
          "bulan": bulanYM,
          "status": "Menunggu Konfirmasi",
        },
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = json.decode(response.body);

        if (decoded is Map<String, dynamic> &&
            decoded["success"] == true &&
            decoded["id_pembayaran"] != null) {
          final idPembayaran = decoded["id_pembayaran"].toString();

          await http.post(
            Uri.parse("http://192.168.182.125/simko_api/kirim_notif.php"),
            body: {
              "id_penghuni": widget.idPenghuni,
              "pesan": "Pembayaran bulan $bulan menunggu konfirmasi.",
              "id_ref": idPembayaran,
              "target": "admin",
            },
          );

          if (metode == "Transfer") {
            final picked = await ImagePicker().pickImage(
              source: ImageSource.gallery,
            );
            if (picked != null) {
              final success = await UploadService.uploadBuktiTransfer(
                idPembayaran,
                picked,
              );
              if (!success) {
                _showSnackbar("Upload bukti transfer gagal");
              }
            }
          }

          Navigator.pushReplacementNamed(
            context,
            '/menunggu-konfirmasi',
            arguments: {
              'idPenghuni': widget.idPenghuni,
              'ym': bulanYM,
              'bulan': bulan,
            },
          );
        } else {
          _showSnackbar(decoded["message"] ?? "Gagal mengirim pembayaran.");
        }
      } else {
        _showSnackbar(
          "Gagal menghubungi server. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      _showSnackbar("Terjadi kesalahan: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(
          "Pembayaran Awal",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF014C5E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kamar: ${widget.kamar}",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "Metode Pembayaran",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: metode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              items:
                  ["Cash", "Transfer"].map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(
                        e == 'Transfer' ? '$e (DANA: 081214261646)' : e,
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => metode = val);
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Nominal Pembayaran",
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _catatanController,
              decoration: InputDecoration(
                labelText: "Catatan (Opsional)",
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF014C5E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon:
                    isLoading
                        ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.send, color: Colors.white),
                label: Text(
                  isLoading ? "Mengirim..." : "Kirim Pembayaran",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onPressed: isLoading ? null : _submitPembayaran,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
