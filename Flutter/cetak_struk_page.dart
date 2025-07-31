import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CetakStrukPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const CetakStrukPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ');
    final tanggal = DateFormat(
      'dd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(DateTime.parse(data['tanggal']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Pembayaran'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Struk Pembayaran Kost',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 30),
                buildRow('Nama Penghuni', data['nama_penghuni'] ?? '-'),
                buildRow('Tanggal Pembayaran', tanggal),
                buildRow('Metode Pembayaran', data['metode']),
                if (data['metode'] == 'transfer') ...[
                  buildRow('Nomor Dana', data['nomor_dana'] ?? '-'),
                  buildRow('Nama Dana', data['nama_dana'] ?? '-'),
                ],
                buildRow('Status', data['status']),
                buildRow('Nominal', formatter.format(int.parse(data['harga']))),
                const Spacer(),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '~ SIMKO System ~',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
