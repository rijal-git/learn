import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
import 'profil_page.dart';

class NotifikasiPenghuniPage extends StatefulWidget {
  const NotifikasiPenghuniPage({super.key});

  @override
  _NotifikasiPenghuniPageState createState() => _NotifikasiPenghuniPageState();
}

class _NotifikasiPenghuniPageState extends State<NotifikasiPenghuniPage> {
  List<dynamic> notifikasiList = [];

  @override
  void initState() {
    super.initState();
    fetchNotifikasi();
  }

  Future<void> fetchNotifikasi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idPenghuni = prefs.getString('id_penghuni') ?? '0';

      final url =
          'http://192.168.182.125/simko_api/notifikasi_penghuni.php?id_penghuni=$idPenghuni';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          notifikasiList = json.decode(response.body);
        });
      } else {
        debugPrint('Gagal memuat notifikasi');
      }
    } catch (e) {
      debugPrint('Error fetchNotifikasi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi Penghuni"),
        backgroundColor: const Color(0xFF014C5E),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            notifikasiList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: notifikasiList.length,
                  itemBuilder: (context, index) {
                    final notif = notifikasiList[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.notifications_active,
                          color: Color(0xFF014C5E),
                        ),
                        title: Text(
                          notif['judul'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(notif['pesan']),
                        trailing: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                      ),
                    );
                  },
                ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF014C5E),
        unselectedItemColor: Colors.grey[600],
        backgroundColor: const Color(0xFFECECEC),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const DashboardPage(role: 'penghuni'),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfilPage(role: 'penghuni'),
              ),
            );
          }
        },
      ),
    );
  }
}
