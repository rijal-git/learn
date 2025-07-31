import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormBerhentiSewaPage extends StatefulWidget {
  final int idPenghuni;

  const FormBerhentiSewaPage({super.key, required this.idPenghuni});

  @override
  State<FormBerhentiSewaPage> createState() => _FormBerhentiSewaPageState();
}

class _FormBerhentiSewaPageState extends State<FormBerhentiSewaPage> {
  final alasanController = TextEditingController();

  Future<void> kirimPermintaanBerhenti() async {
    final response = await http.post(
      Uri.parse('http://192.168.182.125/simko_api/berhenti_sewa.php'),
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
      appBar: AppBar(title: const Text("Form Berhenti Sewa")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Alasan Berhenti:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: alasanController,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: kirimPermintaanBerhenti,
              child: const Text("Kirim"),
            ),
          ],
        ),
      ),
    );
  }
}
