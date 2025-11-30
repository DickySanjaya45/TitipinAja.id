import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dashboard/dashboard_user.dart';
import 'dashboard/dashboard_admin.dart';

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

      // Halaman awal
      initialRoute: '/login',

      // Routing halaman statis
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard_admin': (context) => const DashboardAdmin(),
      },

      // Handle routes dengan parameters
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard_user') {
          final args = settings.arguments as Map<String, dynamic>?;
          
          return MaterialPageRoute(
            builder: (context) => DashboardUser(
              userData: args?['userData'] ?? {},
              token: args?['token'] ?? '',
            ),
          );
        }

        return null;
      },

      // Route fallback untuk 404
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundPage(),
        );
      },
    );
  }
}

// Halaman fallback 404
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B2B9C),
        foregroundColor: Colors.white,
        title: const Text('404 - Halaman Tidak Ditemukan'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'Oops! Halaman yang kamu cari tidak tersedia.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B2B9C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kembali ke Login'),
            ),
          ],
        ),
      ),
    );
  }
}