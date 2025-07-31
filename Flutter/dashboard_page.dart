import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_sewa_page.dart';
import 'keuangan_page.dart';
import 'komplain_admin_page.dart';
import 'komplain_penghuni_page.dart';
import 'kost_page.dart';
import 'notifikasi_admin_page.dart';
import 'notifikasi_penghuni_page.dart';
import 'pembayaran_page.dart'; // ✅ sudah sesuai
import 'penghuni_page.dart';
import 'profil_page.dart';

class DashboardPage extends StatefulWidget {
  final String role;

  const DashboardPage({super.key, required this.role});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          if (widget.role == 'penghuni') _buildPenghuniContent(),
          if (widget.role == 'admin') _buildAdminContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFF014C5E),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
      ),
      padding: const EdgeInsets.all(20),
      alignment: Alignment.centerLeft,
      child: Image.asset('assets/simko_logo.png', height: 80),
    );
  }

  Widget _buildPenghuniContent() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDashboardTile(
            icon: Icons.account_balance_wallet,
            label: 'Pembayaran',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PembayaranPage(userId: idPenghuni),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildDashboardTile(
            icon: Icons.meeting_room,
            label: 'Data Sewa',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    int idPenghuniInt = 0;
                    try {
                      idPenghuniInt = int.parse(idPenghuni);
                    } catch (e) {
                      print("Gagal mengonversi idPenghuni: $e");
                    }
                    return DataSewaPage(idPenghuni: idPenghuniInt);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildDashboardTile(
            icon: Icons.chat,
            label: 'Komplain',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KomplainPenghuniPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 19,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardTile(
              icon: Icons.meeting_room,
              label: 'Manajemen Kost',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KostPage()),
                );
              },
            ),
            _buildDashboardTile(
              icon: Icons.group,
              label: 'Manajemen Penghuni',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PenghuniPage()),
                );
              },
            ),
            _buildDashboardTile(
              icon: Icons.attach_money,
              label: 'Manajemen Keuangan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KeuanganPage()),
                );
              },
            ),
            _buildDashboardTile(
              icon: Icons.chat,
              label: 'Data Komplain',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KomplainAdminPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[600],
      backgroundColor: const Color(0xFFECECEC),
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            if (widget.role == 'admin') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotifikasiAdminPage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotifikasiPenghuniPage(),
                ),
              );
            }
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfilPage(role: widget.role)),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: 'Notifikasi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }

  Widget _buildDashboardTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFB2D7ED),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.black),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
