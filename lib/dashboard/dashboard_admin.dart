import 'package:flutter/material.dart';
import '../pages/login_page.dart';

// Pages
import 'pengguna_page.dart';
import 'page_operasional.dart'; // Halaman Utama Petugas
import 'riwayat_page.dart';
import 'motor_page.dart'; 
import 'parkir_page.dart'; // Manajemen Slot

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
    // Daftar Halaman
    final List<Widget> pages = [
      PageOperasional(token: widget.token), // CORE FEATURE: Masuk/Keluar
      ParkirPage(token: widget.token),      // Manajemen Slot (ParkirSlotController)
      MotorPage(token: widget.token),       // Master Data Motor
      PenggunaPage(token: widget.token),    // Master Data Pengguna
      RiwayatPage(token: widget.token),     // Laporan
    ];

    final List<String> titles = [
      "Operasional Parkir",
      "Kelola Slot",
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
          NavigationDestination(
            icon: Icon(Icons.local_parking_rounded),
            label: 'Operasional',
          ),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Slot'),
          NavigationDestination(icon: Icon(Icons.two_wheeler), label: 'Motor'),
          NavigationDestination(icon: Icon(Icons.people), label: 'User'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}