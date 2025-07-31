// ========================= FLUTTER: profil_page.dart =========================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilPage extends StatefulWidget {
  final String role;
  const ProfilPage({super.key, required this.role});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String idPenghuni = '';

  @override
  void initState() {
    super.initState();
    _loadIdPenghuni();
  }

  Future<void> _loadIdPenghuni() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idPenghuni = prefs.getString('id_penghuni') ?? '';
    });
  }

  void navigateToDetail(
    String title,
    String kategori, {
    bool canEdit = false,
  }) async {
    String content = '';

    try {
      if (title == 'Identitas' && widget.role != 'admin') {
        final url = Uri.parse(
          'http://192.168.182.125/simko_api/get_identitas_penghuni.php?id_penghuni=$idPenghuni',
        );
        final res = await http.get(url);
        print('BODY IDENTITAS PENGHUNI: ${res.body}');
        var data = json.decode(res.body);
        content = data['isi'] ?? 'Gagal ambil identitas';
      } else {
        final url = Uri.parse(
          'http://192.168.182.125/simko_api/get_profil.php?kategori=$kategori',
        );
        final res = await http.get(url);
        print('BODY INFORMASI UMUM: ${res.body}');
        var data = json.decode(res.body);
        content = data['isi'] ?? '';
      }
    } catch (e) {
      content = 'Terjadi kesalahan: $e';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => DetailPage(
              title: title,
              kategori: kategori,
              content: content,
              canEdit: canEdit,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 10, 70, 95),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Identitas"),
            onTap:
                () => navigateToDetail(
                  "Identitas",
                  "Identitas",
                  canEdit: widget.role == 'admin',
                ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text("Panduan Aplikasi"),
            onTap:
                () => navigateToDetail(
                  "Panduan Aplikasi",
                  "Panduan Aplikasi",
                  canEdit: widget.role == 'admin',
                ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text("Hubungi Kami"),
            onTap:
                () => navigateToDetail(
                  "Hubungi Kami",
                  "Hubungi Kami",
                  canEdit: widget.role == 'admin',
                ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Syarat dan Ketentuan"),
            onTap:
                () => navigateToDetail(
                  "Syarat dan Ketentuan",
                  "Syarat dan Ketentuan",
                  canEdit: widget.role == 'admin',
                ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Keluar"),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final String title;
  final String kategori;
  final String content;
  final bool canEdit;

  const DetailPage({
    super.key,
    required this.title,
    required this.kategori,
    required this.content,
    this.canEdit = false,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
  }

  void _saveChanges() async {
    final res = await http.post(
      Uri.parse('http://192.168.182.125/simko_api/update_profil.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"kategori": widget.kategori, "isi": _controller.text}),
    );

    final data = json.decode(res.body);
    if (data['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Perubahan disimpan")));
      setState(() => _isEditing = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan perubahan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 10, 70, 95),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.canEdit && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isEditing
                ? Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text("Simpan"),
                    ),
                  ],
                )
                : Text(_controller.text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
