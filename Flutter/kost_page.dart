import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_kost_page.dart';

class KostPage extends StatefulWidget {
  const KostPage({super.key});

  @override
  State<KostPage> createState() => _KostPageState();
}

class _KostPageState extends State<KostPage> {
  final _baseUrl = 'http://192.168.182.125/simko_api';
  List<dynamic> kostList = [];
  Map<String, int> jumlahTerisi = {};

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final kostRes = await http.get(Uri.parse('$_baseUrl/get_kost.php'));
    final terisiRes = await http.get(
      Uri.parse('$_baseUrl/get_kost_terisi.php'),
    );

    if (kostRes.statusCode == 200 && terisiRes.statusCode == 200) {
      final List kostData = json.decode(kostRes.body);
      final Map terisiData = json.decode(terisiRes.body);

      setState(() {
        kostList = kostData;
        jumlahTerisi = terisiData.map(
          (k, v) => MapEntry(k.toString(), int.parse(v.toString())),
        );
      });
    }
  }

  Future<void> _delete(String id) async {
    final r = await http.post(
      Uri.parse('$_baseUrl/delete_kost.php'),
      body: {'id': id},
    );
    if (r.statusCode == 200) _fetch();
  }

  @override
  Widget build(BuildContext ctx) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Manajemen Kost',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 10, 70, 95),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body:
        kostList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
              itemCount: kostList.length,
              itemBuilder: (c, i) {
                final k = kostList[i];
                final jumlah = jumlahTerisi[k['id']] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text('Kamar: ${k['kamar']}'),
                    subtitle: Text(
                      'Harga: ${k['harga']}\nFasilitas: ${k['fasilitas']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Terisi: $jumlah',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(k['id'].toString()),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => DetailKostPage(
                                kamar: k['kamar'],
                                isEdit: true,
                                kostData: k,
                              ),
                        ),
                      );
                      if (res == 'success') _fetch();
                    },
                  ),
                );
              },
            ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add),
      onPressed: () async {
        final res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DetailKostPage(kamar: '', isEdit: false),
          ),
        );
        if (res == 'success') _fetch();
      },
    ),
  );
}
