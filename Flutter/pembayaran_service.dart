import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';

class PembayaranService {
  static const String _baseUrl = 'http://192.168.182.125/simko_api';

  static Future<List<Map<String, dynamic>>> fetchPembayaran12Bulan(
    String userId,
  ) async {
    final res = await http.get(
      Uri.parse("$_baseUrl/get_pembayaran_12_bulan.php?id_penghuni=$userId"),
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Gagal mengambil data pembayaran");
    }
  }

  static Future<String?> submitPembayaran({
    required String idPenghuni,
    required String bulan,
    required String metode,
    required String nominal,
  }) async {
    try {
      final now = DateTime.now();
      final ym = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      final res = await http.post(
        Uri.parse("$_baseUrl/add_pembayaran.php"),
        body: {
          "id_penghuni": idPenghuni,
          "kamar": "-",
          "metode": metode,
          "nominal": nominal,
          "catatan": "Pembayaran bulan $bulan",
          "bulan": bulan,
          "bulan_ym": ym,
          "status": "Menunggu Konfirmasi",
        },
      );

      final data = jsonDecode(res.body);
      if (data['success'] == true && data['id_pembayaran'] != null) {
        final idPembayaran = data['id_pembayaran'].toString();

        await http.post(
          Uri.parse("$_baseUrl/kirim_notif.php"),
          body: {
            "id_penghuni": idPenghuni,
            "pesan": "Pembayaran bulan $bulan menunggu konfirmasi.",
            "id_ref": idPembayaran,
            "target": "admin",
          },
        );

        return idPembayaran;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

class UploadService {
  static Future<bool> uploadBuktiTransfer(
    String idPembayaran,
    XFile file,
  ) async {
    final uri = Uri.parse(
      "http://192.168.182.125/simko_api/upload_bukti_transfer.php",
    );
    final request = http.MultipartRequest("POST", uri);
    request.fields['id_pembayaran'] = idPembayaran;

    final bytes = await file.readAsBytes();
    final mimeType = lookupMimeType(file.name) ?? 'application/octet-stream';
    final parts = mimeType.split('/');

    request.files.add(
      http.MultipartFile.fromBytes(
        'bukti_transfer',
        bytes,
        filename: file.name,
        contentType: MediaType(parts[0], parts[1]),
      ),
    );

    final response = await request.send();
    final result = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(result);

    return jsonResponse['success'] == true;
  }
}
