import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KomplainPenghuniPage extends StatefulWidget {
  const KomplainPenghuniPage({super.key});

  @override
  State<KomplainPenghuniPage> createState() => _KomplainPenghuniPageState();
}

class _KomplainPenghuniPageState extends State<KomplainPenghuniPage> {
  final _formKey = GlobalKey<FormState>();
  final _tentangController = TextEditingController();
  final _pesanController = TextEditingController();
  String? _selectedKamar;

  final String _baseUrl = 'http://192.168.182.125/simko_api';
  List<String> kamarList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKamarList();
  }

  Future<void> fetchKamarList() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/get_kost.php'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          kamarList = List<String>.from(data.map((e) => e['kamar'].toString()));
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data kamar');
      }
    } catch (e) {
      debugPrint('❌ FETCH KAMAR ERROR: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil daftar kamar')),
      );
    }
  }

  Future<void> kirimKomplain() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final idPenghuni = prefs.getString('id_penghuni');

      if (idPenghuni == null || idPenghuni.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID penghuni tidak ditemukan. Silakan login ulang.'),
          ),
        );
        return;
      }

      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/submit_complain.php'),
          body: {
            'id_penghuni': idPenghuni,
            'kamar': _selectedKamar!,
            'tentang': _tentangController.text,
            'pesan': _pesanController.text,
          },
        );

        final result = json.decode(response.body);
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Komplain berhasil dikirim')),
          );
          _tentangController.clear();
          _pesanController.clear();
          setState(() => _selectedKamar = null);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menyimpan komplain'),
            ),
          );
        }
      } catch (e) {
        debugPrint("❌ ERROR SAAT KIRIM KOMPLAIN: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kesalahan saat mengirim komplain')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Komplain'),
        backgroundColor: const Color(0xFF014C5E), // warna biru tua
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Pilih Kamar',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedKamar,
                        items:
                            kamarList.map((kamar) {
                              return DropdownMenuItem(
                                value: kamar,
                                child: Text(kamar),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedKamar = value);
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Pilih kamar terlebih dahulu'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tentangController,
                        decoration: const InputDecoration(
                          labelText: 'Tentang Komplain',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Isi tentang komplain' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pesanController,
                        decoration: const InputDecoration(
                          labelText: 'Pesan Komplain',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Isi pesan komplain' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: kirimKomplain,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF014C5E),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Kirim'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
