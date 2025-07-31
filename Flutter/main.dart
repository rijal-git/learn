import 'package:flutter/material.dart';
import 'package:flutter_application_simko/login_page.dart';
import 'package:flutter_application_simko/menunggu_konfirmasi_page.dart';
import 'package:flutter_application_simko/pembayaran_awal_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMKO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: LoginPage.routeName,
      routes: {LoginPage.routeName: (context) => const LoginPage()},
      onGenerateRoute: (settings) {
        if (settings.name == '/pembayaran-awal') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null ||
              args['idPenghuni'] == null ||
              args['kamar'] == null) {
            debugPrint('ERROR: Argument /pembayaran-awal tidak lengkap: $args');
            return null;
          }

          return MaterialPageRoute(
            builder:
                (_) => PembayaranAwalPage(
                  kamar: args['kamar'],
                  idPenghuni: args['idPenghuni'],
                ),
          );
        } else if (settings.name == '/menunggu-konfirmasi') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null ||
              args['idPenghuni'] == null ||
              args['ym'] == null ||
              args['bulan'] == null) {
            debugPrint(
              'ERROR: Argument /menunggu-konfirmasi tidak lengkap: $args',
            );
            return null;
          }

          debugPrint('Navigasi ke /menunggu-konfirmasi dengan argumen: $args');

          return MaterialPageRoute(
            builder:
                (_) => MenungguKonfirmasiPage(
                  idPenghuni: args['idPenghuni'].toString(),
                  ym: args['ym'].toString(),
                  bulan: args['bulan'].toString(),
                ),
          );
        }
        return null;
      },
    );
  }
}
