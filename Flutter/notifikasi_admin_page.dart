import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_page.dart';
import 'profil_page.dart';

class NotifikasiAdminPage extends StatefulWidget {
  const NotifikasiAdminPage({super.key});

  @override
  State<NotifikasiAdminPage> createState() => _NotifikasiAdminPageState();
}

class _NotifikasiAdminPageState extends State<NotifikasiAdminPage>
    with TickerProviderStateMixin {
  late TabController _tab;
  List pindah = [], berhenti = [], pembayaran = [];
  final TextEditingController judulC = TextEditingController();
  final TextEditingController pesanC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _ambilNotif();
  }

  Future<void> _ambilNotif() async {
    try {
      final pindahRes = await http.get(
        Uri.parse('http://192.168.182.125/simko_api/get_pindah.php'),
      );
      final berhentiRes = await http.get(
        Uri.parse('http://192.168.182.125/simko_api/get_berhenti.php'),
      );
      final bayarRes = await http.get(
        Uri.parse('http://192.168.182.125/simko_api/get_notif_pembayaran.php'),
      );

      if (pindahRes.statusCode == 200) pindah = jsonDecode(pindahRes.body);
      if (berhentiRes.statusCode == 200)
        berhenti = jsonDecode(berhentiRes.body);
      if (bayarRes.statusCode == 200) pembayaran = jsonDecode(bayarRes.body);

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengambil data notifikasi")),
      );
    }
  }

  Future<void> _konfirmasiPembayaran(String idBayar) async {
    final res = await http.post(
      Uri.parse('http://192.168.182.125/simko_api/konfirmasi_pembayaran.php'),
      body: {'id_pembayaran': idBayar, 'aksi': 'terima'},
    );

    final data = jsonDecode(res.body);
    if (data['success'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pembayaran dikonfirmasi')));
      _ambilNotif();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal konfirmasi: ${data['message'] ?? res.body}'),
        ),
      );
    }
  }

  Future<void> _kirimNotif() async {
    if (judulC.text.isEmpty || pesanC.text.isEmpty) return;

    await http.post(
      Uri.parse('http://192.168.182.125/simko_api/kirim_notif.php'),
      body: {
        'id_penghuni': '0',
        'judul': judulC.text,
        'pesan': pesanC.text,
        'target': 'penghuni',
      },
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notifikasi terkirim')));

    judulC.clear();
    pesanC.clear();
  }

  Widget _buildInfoCard(List src) => ListView.builder(
    itemCount: src.length,
    itemBuilder: (context, i) {
      final item = src[i];
      return Card(
        elevation: 2,
        child: ListTile(
          title: Text('Penghuni ID: ${item['id_penghuni']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alasan: ${item['alasan']}'),
              if (item['tanggal'] != null) Text('Tanggal: ${item['tanggal']}'),
            ],
          ),
        ),
      );
    },
  );

  Widget _buildPembayaranCard() => ListView.builder(
    itemCount: pembayaran.length,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (context, i) {
      final item = pembayaran[i];
      return Card(
        elevation: 2,
        child: ListTile(
          title: Text('Penghuni ID: ${item['id_penghuni']}'),
          subtitle: Text(
            'Metode: ${item['metode']} | Nominal: Rp${item['nominal']}',
          ),
          trailing: ElevatedButton(
            onPressed: () => _konfirmasiPembayaran(item['id_pembayaran']),
            child: const Text('Konfirmasi'),
          ),
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifikasi Admin',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 70, 95),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tab,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color.fromARGB(255, 10, 70, 95),
              tabs: const [Tab(text: 'Kirim'), Tab(text: 'Terima')],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: judulC,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pesanC,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Pesan'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _kirimNotif,
                  icon: const Icon(Icons.send),
                  label: const Text('Kirim Notifikasi'),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Permintaan Pindah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(height: 200, child: _buildInfoCard(pindah)),

                const SizedBox(height: 16),
                const Text(
                  'Permintaan Berhenti',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(height: 200, child: _buildInfoCard(berhenti)),

                const SizedBox(height: 16),
                const Text(
                  'Pembayaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                pembayaran.isEmpty
                    ? const Text("Belum ada notifikasi pembayaran.")
                    : _buildPembayaranCard(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(1),
    );
  }

  BottomNavigationBar _buildBottomNav(int index) {
    return BottomNavigationBar(
      currentIndex: index,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[600],
      backgroundColor: const Color(0xFFECECEC),
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
      onTap: (idx) {
        if (idx == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DashboardPage(role: 'admin'),
            ),
          );
        } else if (idx == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProfilPage(role: 'admin')),
          );
        }
      },
    );
  }
}
