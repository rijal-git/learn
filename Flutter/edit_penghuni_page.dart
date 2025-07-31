import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditPenghuniPage extends StatefulWidget {
  final Map<String, dynamic> dataPenghuni;

  const EditPenghuniPage({super.key, required this.dataPenghuni});

  @override
  State<EditPenghuniPage> createState() => _EditPenghuniPageState();
}

class _EditPenghuniPageState extends State<EditPenghuniPage> {
  late TextEditingController namaController;
  late TextEditingController alamatController;
  late TextEditingController emailController;
  late TextEditingController teleponController;
  late TextEditingController usernameController;
  late TextEditingController tanggalMasukController;
  late String aktifValue;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.dataPenghuni['nama']);
    alamatController = TextEditingController(
      text: widget.dataPenghuni['alamat'],
    );
    emailController = TextEditingController(text: widget.dataPenghuni['email']);
    teleponController = TextEditingController(
      text: widget.dataPenghuni['telepon'],
    );
    usernameController = TextEditingController(
      text: widget.dataPenghuni['username'],
    );
    tanggalMasukController = TextEditingController(
      text: widget.dataPenghuni['tanggal_masuk'],
    );
    aktifValue = widget.dataPenghuni['aktif'].toString(); // '0' atau '1'
  }

  @override
  void dispose() {
    namaController.dispose();
    alamatController.dispose();
    emailController.dispose();
    teleponController.dispose();
    usernameController.dispose();
    tanggalMasukController.dispose();
    super.dispose();
  }

  Future<void> _simpanData() async {
    final response = await http.post(
      Uri.parse("http://192.168.182.125/simko_api/update_penghuni.php"),
      body: {
        'id': widget.dataPenghuni['id'].toString(),
        'nama': namaController.text,
        'alamat': alamatController.text,
        'email': emailController.text,
        'telepon': teleponController.text,
        'username': usernameController.text,
        'tanggal_masuk': tanggalMasukController.text,
        'aktif': aktifValue,
      },
    );

    if (response.statusCode == 200 && response.body.contains('success')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data penghuni berhasil diperbarui')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui data penghuni')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Penghuni',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 70, 95),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: alamatController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: teleponController,
              decoration: const InputDecoration(labelText: 'Telepon'),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: tanggalMasukController,
              decoration: const InputDecoration(labelText: 'Tanggal Masuk'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: aktifValue,
              items: const [
                DropdownMenuItem(value: '1', child: Text('Aktif')),
                DropdownMenuItem(value: '0', child: Text('Tidak Aktif')),
              ],
              onChanged: (value) {
                setState(() {
                  aktifValue = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Status Aktif'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _simpanData,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
