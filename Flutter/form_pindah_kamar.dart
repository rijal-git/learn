import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormPindahKamarPage extends StatefulWidget {
  final int idPenghuni;

  const FormPindahKamarPage({super.key, required this.idPenghuni});

  @override
  State<FormPindahKamarPage> createState() => _FormPindahKamarPageState();
}

class _FormPindahKamarPageState extends State<FormPindahKamarPage> {
  final alasanController = TextEditingController();

  Future<void> kirimPermintaanPindah() async {
    final response = await http.post(
      Uri.parse('http://192.168.182.125/simko_api/pindah_kamar.php'),
      body: {
        'id_penghuni': widget.idPenghuni.toString(),
        'alasan': alasanController.text,
      },
    );

    if (response.statusCode == 200 && response.body == 'success') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Permintaan terkirim')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim permintaan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Pindah Kamar"),
        backgroundColor: const Color.fromARGB(255, 10, 70, 95),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Alasan Pindah:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: alasanController,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: kirimPermintaanPindah,
              child: const Text("Kirim"),
            ),
          ],
        ),
      ),
    );
  }
}
