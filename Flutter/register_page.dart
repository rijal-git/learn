// ====== Import External Packages ======
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ====== Import Internal Pages ======
import 'pesan_kost_page.dart';
import 'login_page.dart';

// ====== Register Page ======
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tanggalMasukController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    // Validasi input
    if (_namaController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _telpController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _tanggalMasukController.text.isEmpty) {
      _showDialog("Error", "Semua field harus diisi.");
      return;
    }

    // Debug: Print semua field yang akan dikirim ke server
    print('Mengirim data registrasi:');
    print('nama: ${_namaController.text}');
    print('alamat: ${_alamatController.text}');
    print('email: ${_emailController.text}');
    print('telepon: ${_telpController.text}');
    print('username: ${_usernameController.text}');
    print('password: ${_passwordController.text}');
    print('tanggal_masuk: ${_tanggalMasukController.text}');

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.182.125/simko_api/register.php'),
        body: {
          'nama': _namaController.text.trim(),
          'alamat': _alamatController.text.trim(),
          'email': _emailController.text.trim(),
          'telepon': _telpController.text.trim(),
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
          'tanggal_masuk': _tanggalMasukController.text.trim(),
        },
      );

      print("Respon dari server: ${response.body}");
      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        // Simpan id_penghuni ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('id_penghuni', result['id_penghuni'].toString());

        // Navigasi ke halaman pesan kost
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    PesanKostPage(idPenghuni: result['id_penghuni'].toString()),
          ),
        );
      } else {
        _showDialog("Gagal", result['message'] ?? "Registrasi gagal.");
      }
    } catch (e) {
      _showDialog("Error", "Terjadi kesalahan: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _tanggalMasukController.text = picked.toIso8601String().substring(0, 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D5C8B),
      body: Column(
        children: [
          // Bagian Atas (Logo dan Judul)
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/simko_logo.png", height: 100),
                  SizedBox(height: 8),
                  Text(
                    "SIMKO",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Sistem Informasi Manajemen Kost",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Form Registrasi
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    _buildInputField(_namaController, 'Nama Lengkap'),
                    _buildInputField(_alamatController, 'Alamat'),
                    _buildInputField(
                      _emailController,
                      'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildInputField(
                      _telpController,
                      'No Telepon',
                      keyboardType: TextInputType.phone,
                    ),
                    _buildInputField(_usernameController, 'Username'),
                    _buildInputField(
                      _passwordController,
                      'Password',
                      isPassword: true,
                    ),
                    _buildDateInput(_tanggalMasukController, 'Tanggal Masuk'),
                    SizedBox(height: 20),

                    // Tombol Daftar
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child:
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    28,
                                    122,
                                    199,
                                  ),
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _register,
                                child: const Text("Daftar"),
                              ),
                    ),

                    SizedBox(height: 10),

                    // Navigasi ke Login
                    GestureDetector(
                      onTap: _navigateToLogin,
                      child: RichText(
                        text: TextSpan(
                          text: "Sudah punya akun? ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Masuk",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hintText, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDateInput(TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: _pickDate,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: Icon(Icons.calendar_today),
        ),
      ),
    );
  }
}
