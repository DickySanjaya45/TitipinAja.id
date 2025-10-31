import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dashboard/dashboard_admin.dart';
import 'dashboard/dashboard_user.dart';

void main() {
  runApp(const TitipinAjaApp());
}

class TitipinAjaApp extends StatelessWidget {
  const TitipinAjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TitipinAja.id',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.deepPurple[50],
        useMaterial3: true,
      ),
      // Halaman pertama saat aplikasi dijalankan
      initialRoute: '/login',

      // Routing antar halaman
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard_admin': (context) => const DashboardAdmin(),
        '/dashboard_user': (context) => const DashboardUser(userData: {}, token: ''),
      },

      // Jika route tidak ditemukan
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundPage(),
        );
      },
    );
  }
}

// Halaman fallback jika route tidak ditemukan
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          '404 - Halaman Tidak Ditemukan',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Oops! Halaman yang kamu cari tidak tersedia.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
