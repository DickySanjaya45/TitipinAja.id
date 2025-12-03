import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../pages/login_page.dart';

// Pages
import 'pengguna_page.dart';
import 'page_operasional.dart'; // NEW PAGE
import 'riwayat_page.dart';
import 'motor_page.dart'; // Master Data Motor

class DashboardAdmin extends StatefulWidget {
  final String token;
  final Map<String, dynamic> adminData;

  const DashboardAdmin({
    super.key,
    required this.token,
    required this.adminData,
  });

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _selectedIndex = 0;

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _HomeAdminPlaceholder(), // Dashboard Overview sederhana
      PageOperasional(
        token: widget.token,
      ), // CORE FEATURE: Masuk, Keluar, Bayar
      MotorPage(token: widget.token), // Data Master Motor
      PenggunaPage(token: widget.token), // Data Master Pengguna
      RiwayatPage(token: widget.token), // Laporan
    ];

    final List<String> titles = [
      "Dashboard",
      "Operasional Parkir",
      "Data Motor",
      "Data Pengguna",
      "Riwayat Transaksi",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        backgroundColor: const Color(0xFF5B2B9C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.local_parking),
            label: 'Operasional',
          ),
          NavigationDestination(icon: Icon(Icons.two_wheeler), label: 'Motor'),
          NavigationDestination(icon: Icon(Icons.people), label: 'User'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}

class _HomeAdminPlaceholder extends StatelessWidget {
  const _HomeAdminPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            "Selamat Datang, Admin!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text("Gunakan menu 'Operasional' untuk proses parkir."),
        ],
      ),
    );
  }
}
