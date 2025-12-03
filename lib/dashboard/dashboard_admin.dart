import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // Pastikan path ini benar
import '../pages/login_page.dart'; // Pastikan path ini benar

// Import halaman-halaman menu
import 'pengguna_page.dart';
import 'motor_page.dart';
import 'pembayaran_page.dart';
import 'riwayat_page.dart';
import 'parkir_page.dart';
import 'pengaturan_page.dart';

class DashboardAdmin extends StatefulWidget {
  final String token;
  final Map<String, dynamic> adminData;

  const DashboardAdmin({
    super.key, 
    required this.token, 
    required this.adminData
  });

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _selectedIndex = 0;
  bool _isLoggingOut = false;

  // Fungsi Logout
  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);

    // 1. Request Logout ke Backend
    await ApiService.logout(widget.token);

    if (!mounted) return;

    // 2. Navigasi balik ke Login & Hapus semua history stack
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const LoginPage()), 
      (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil Data Admin dengan Null Safety
    // Pastikan key 'nama_petugas' sesuai dengan respon JSON login Anda
    String adminName = widget.adminData['nama_petugas'] ?? widget.adminData['nama'] ?? 'Admin';
    String adminShift = widget.adminData['shift_kerja'] ?? 'All Shift';

    // Cek Lebar Layar (Responsif)
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      
      // AppBar & Drawer hanya muncul di Mobile
      appBar: isMobile 
          ? AppBar(
              title: const Text("Admin Panel", style: TextStyle(color: Colors.black87)), 
              backgroundColor: Colors.white,
              elevation: 1,
              iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
            ) 
          : null,
      drawer: isMobile ? _buildSidebar(adminName, adminShift) : null,
      
      body: Row(
        children: [
          // === SIDEBAR (Desktop/Tablet) ===
          if (!isMobile) 
            SizedBox(
              width: 260,
              child: _buildSidebar(adminName, adminShift),
            ),

          // === MAIN CONTENT ===
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.05 * 255).round()),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              // ClipRRect agar konten tidak keluar dari radius
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Sidebar (Reusable)
  Widget _buildSidebar(String name, String shift) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header Profil
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.admin_panel_settings, 
                    size: 48, 
                    color: Theme.of(context).primaryColor
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text(
                    "Shift: $shift",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
          
          // Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMenuItem(0, "Dashboard", Icons.dashboard_outlined),
                _buildMenuItem(1, "Pengguna", Icons.people_outline),
                _buildMenuItem(2, "Motor", Icons.two_wheeler),
                _buildMenuItem(3, "Pembayaran", Icons.payments_outlined),
                _buildMenuItem(4, "Riwayat", Icons.history),
                _buildMenuItem(5, "Slot Parkir", Icons.local_parking),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
                _buildMenuItem(6, "Pengaturan", Icons.settings_outlined),
              ],
            ),
          ),

          // Tombol Logout
          Padding(
            padding: const EdgeInsets.all(20),
            child: InkWell(
              onTap: _isLoggingOut ? null : _handleLogout,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoggingOut 
                  ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red)))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Item Menu
  Widget _buildMenuItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
           setState(() => _selectedIndex = index);
           // Jika di mobile, tutup drawer otomatis setelah klik
           if (MediaQuery.of(context).size.width < 800 && Scaffold.of(context).hasDrawer) {
             Navigator.pop(context); 
           }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? primaryColor : Colors.transparent,
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  // Switcher Konten Utama
  Widget _buildContent() {
    // PENTING:
    // Pastikan MotorPage, RiwayatPage, dll sudah diupdate konstruktornya 
    // agar menerima parameter 'token'.
    switch (_selectedIndex) {
      case 0: return _buildHomeDashboard();
      case 1: return PenggunaPage(token: widget.token); // Sudah kita perbaiki
      case 2: return MotorPage(token: widget.token); // <--- Perlu update file MotorPage
      case 3: return PembayaranPage(token: widget.token); // <--- Perlu update file PembayaranPage
      case 4: return RiwayatPage(token: widget.token); // <--- Perlu update file RiwayatPage
      case 5: return ParkirPage(token: widget.token); // <--- Perlu update file ParkirPage
      case 6: return PengaturanPage(token: widget.token, adminData: widget.adminData);
      default: return const SizedBox();
    }
  }

  // Halaman Dashboard Home (Statistik)
  Widget _buildHomeDashboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "Halo, ${widget.adminData['nama_petugas'] ?? 'Admin'}!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 8),
          const Text(
            "Selamat bekerja! Kelola sistem parkir dari menu samping.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}