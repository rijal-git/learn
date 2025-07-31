import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart'; // ✅ penting!

class DetailKostPage extends StatefulWidget {
  final String kamar;
  final bool isEdit;
  final dynamic kostData;

  const DetailKostPage({
    super.key,
    required this.kamar,
    required this.isEdit,
    this.kostData,
  });

  @override
  State<DetailKostPage> createState() => _DetailKostPageState();
}

class _DetailKostPageState extends State<DetailKostPage> {
  final _baseUrl = 'http://192.168.182.125/simko_api';

  late final TextEditingController _kamarC;
  late final TextEditingController _ukuranC;
  late final TextEditingController _hargaC;
  late final TextEditingController _statusC;
  late final TextEditingController _fasilitasC;

  XFile? _selectedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _kamarC = TextEditingController(
      text: widget.isEdit ? widget.kostData['kamar'] : widget.kamar,
    );
    _ukuranC = TextEditingController(
      text: widget.isEdit ? widget.kostData['ukuran'] : '',
    );
    _hargaC = TextEditingController(
      text: widget.isEdit ? widget.kostData['harga'].toString() : '',
    );
    _statusC = TextEditingController(
      text: widget.isEdit ? widget.kostData['status'] : 'Kosong',
    );
    _fasilitasC = TextEditingController(
      text: widget.isEdit ? widget.kostData['fasilitas'] : '',
    );

    if (widget.isEdit && widget.kostData['gambar'] != null) {
      _imageUrl = widget.kostData['gambar'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = picked);
    }
  }

  Future<void> _saveKost() async {
    final uri = Uri.parse(
      '$_baseUrl/${widget.isEdit ? 'edit_kost.php' : 'add_kost.php'}',
    );
    final req = http.MultipartRequest('POST', uri);

    if (widget.isEdit) {
      req.fields['id'] = widget.kostData['id'].toString();
    }

    req.fields['kamar'] = _kamarC.text;
    req.fields['ukuran'] = _ukuranC.text;
    req.fields['harga'] = _hargaC.text;
    req.fields['status'] = _statusC.text;
    req.fields['fasilitas'] = _fasilitasC.text;

    if (_selectedImage != null) {
      final fileBytes = await _selectedImage!.readAsBytes();

      // ✅ Cari MIME dan ekstensinya
      final mimeType = lookupMimeType(
        _selectedImage!.path,
        headerBytes: fileBytes,
      );
      String extension = extensionFromMime(mimeType ?? '') ?? '';

      // ✅ Tambahan fallback dari nama file
      if (extension.isEmpty) {
        extension = p.extension(_selectedImage!.path).replaceFirst('.', '');
        if (extension.isEmpty) extension = 'jpg';
      }

      final fileName =
          '${p.basenameWithoutExtension(_selectedImage!.path)}.$extension';

      req.files.add(
        http.MultipartFile.fromBytes('gambar', fileBytes, filename: fileName),
      );

      print("🟨 Kirim data: ${req.fields}");
      print("📷 Upload gambar: $fileName (${fileBytes.length} bytes)");
      print("🧪 MIME type: $mimeType / Ekstensi: $extension");
    } else {
      print("📭 Tidak ada gambar yang dipilih");
    }

    try {
      final res = await req.send();
      final resBody = await res.stream.bytesToString();

      print("✅ RESPON STATUS: ${res.statusCode}");
      print("✅ RESPON BODY: $resBody");

      if (!mounted) return;

      if (res.statusCode == 200 && resBody.contains('"success":true')) {
        Navigator.pop(context, 'success');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $resBody')));
      }
    } catch (e) {
      if (!mounted) return;
      print("⛔ ERROR SAAT UPLOAD: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat upload: $e')),
      );
    }
  }

  Widget _buildInput(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    ),
  );

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
          future: _selectedImage!.readAsBytes(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              );
            }
            return const CircularProgressIndicator();
          },
        );
      } else {
        return Image.file(
          File(_selectedImage!.path),
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        );
      }
    } else if (_imageUrl != null) {
      return Image.network(
        _imageUrl!,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 80),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit Kost' : 'Tambah Kost',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 86, 129),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInput(_kamarC, 'Nomor Kamar'),
            _buildInput(_ukuranC, 'Ukuran (mis: 3x3)'),
            _buildInput(_hargaC, 'Harga (Rp)'),
            _buildInput(_statusC, 'Status (Kosong/Terisi)'),
            _buildInput(_fasilitasC, 'Fasilitas'),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Pilih Gambar'),
                ),
                const SizedBox(width: 10),
                if (_selectedImage != null)
                  Text(p.basename(_selectedImage!.path))
                else if (_imageUrl != null)
                  const Text('Gambar lama digunakan'),
              ],
            ),
            const SizedBox(height: 12),
            _buildImagePreview(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveKost,
              child: Text(widget.isEdit ? 'Simpan Perubahan' : 'Tambah Kost'),
            ),
          ],
        ),
      ),
    );
  }
}
