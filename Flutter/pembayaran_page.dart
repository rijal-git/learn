import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'pembayaran_service.dart';
import 'menunggu_konfirmasi_page.dart';

class PembayaranPage extends StatefulWidget {
  final String userId;
  const PembayaranPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1;
  List<Map<String, dynamic>> semuaPembayaran = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPembayaran();
  }

  Future<void> _fetchPembayaran() async {
    try {
      final data = await PembayaranService.fetchPembayaran12Bulan(
        widget.userId,
      );
      setState(() {
        semuaPembayaran = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengambil data pembayaran")),
      );
    }
  }

  void _tampilkanDialogMetode(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Pilih Metode Pembayaran"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.money),
                  title: const Text("Tunai"),
                  onTap: () {
                    Navigator.pop(context);
                    _kirimPembayaran(item, "Cash");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: const Text("Transfer"),
                  onTap: () {
                    Navigator.pop(context);
                    _kirimPembayaran(item, "Transfer");
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _kirimPembayaran(
    Map<String, dynamic> item,
    String metode,
  ) async {
    final bulanString = item['bulan'];
    final DateTime parsedDate = DateFormat(
      'MMMM yyyy',
      'en_US',
    ).parse(bulanString);
    final String bulanFormatted = DateFormat('yyyy-MM').format(parsedDate);

    debugPrint("📩 Mengirim pembayaran untuk bulan: $bulanFormatted");

    String? idPembayaran = await PembayaranService.submitPembayaran(
      idPenghuni: widget.userId,
      metode: metode,
      bulan: bulanFormatted,
      nominal: item['nominal'].toString(),
    );

    if (idPembayaran != null) {
      if (metode == "Transfer") {
        final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        if (picked != null) {
          final uploadSuccess = await UploadService.uploadBuktiTransfer(
            idPembayaran,
            picked,
          );
          if (!uploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Upload bukti transfer gagal")),
            );
          }
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => MenungguKonfirmasiPage(
                idPenghuni: widget.userId,
                ym: bulanFormatted,
                bulan: bulanString,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengirim pembayaran.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran Kost"),
        backgroundColor: const Color.fromARGB(255, 10, 70, 95),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: "Belum Dibayar"), Tab(text: "Sudah Dibayar")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildList(isBelum: true), _buildList(isBelum: false)],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: "Pembayaran",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifikasi",
          ),
        ],
      ),
    );
  }

  Widget _buildList({required bool isBelum}) {
    if (semuaPembayaran.isEmpty) {
      return const Center(child: Text("Tidak ada data pembayaran."));
    }

    return ListView.builder(
      itemCount: semuaPembayaran.length,
      itemBuilder: (context, i) {
        final item = semuaPembayaran[i];
        final status = item['status'];
        final bulan = item['bulan'];

        Icon statusIcon;
        if (status == "Lunas") {
          statusIcon = const Icon(Icons.check_circle, color: Colors.green);
        } else if (status == "Menunggu Konfirmasi") {
          statusIcon = const Icon(Icons.timelapse, color: Colors.grey);
        } else {
          statusIcon = const Icon(Icons.error_outline, color: Colors.orange);
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(bulan),
            trailing:
                isBelum
                    ? (status == "Belum Dibayar"
                        ? ElevatedButton(
                          onPressed: () => _tampilkanDialogMetode(item),
                          child: const Text("Bayar"),
                        )
                        : statusIcon)
                    : statusIcon,
          ),
        );
      },
    );
  }
}
