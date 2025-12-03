import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // Import ApiService
import '../pages/login_page.dart'; // Import halaman Login

// Import halaman anak
import 'page_motor_saya.dart';
import 'page_member.dart';
import 'page_pembayaran.dart';
import 'page_transaksi_aktif.dart';

class DashboardUser extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String token;

  const DashboardUser({
    super.key, 
    required this.userData, 
    required this.token
  });

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  int _selectedIndex = 0;
  bool _isLoggingOut = false;

  // --- LOGOUT LOGIC ---
  Future<void> _logout() async {
    // Tampilkan loading dialog atau indikator
    setState(() => _isLoggingOut = true);

    await ApiService.logout(widget.token);

    if (!mounted) return;

    // Kembali ke halaman login & hapus semua history
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const LoginPage()), 
      (route) => false
    );
  }

  // --- MENU CONTENT ---
  Widget _buildContent() {
    // Kirim Token & UserData ke halaman anak agar bisa akses API
    switch (_selectedIndex) {
      case 0: 
        return _buildHomeUI(widget.userData, Theme.of(context).colorScheme);
      case 1: 
        return PageMotorSaya(token: widget.token, userData: widget.userData);
      case 2: 
        // Pastikan PageMember punya konstruktor token
        return PageMember(token: widget.token, userData: widget.userData); 
      case 3: 
        // Pastikan PagePembayaran punya konstruktor token
        return PagePembayaran(token: widget.token); 
      default: 
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(), // Gunakan helper function untuk ganti halaman
      
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).round()),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, "Home", Theme.of(context).primaryColor),
            _buildNavItem(1, Icons.two_wheeler_rounded, "Motor", Theme.of(context).primaryColor),
            _buildNavItem(2, Icons.card_membership_rounded, "Member", Theme.of(context).primaryColor),
            _buildNavItem(3, Icons.history_rounded, "Riwayat", Theme.of(context).primaryColor), // Ganti Bayar jadi Riwayat/Bayar
          ],
        ),
      ),
    );
  }

  // UI Khusus Halaman Utama Dashboard
  Widget _buildHomeUI(Map<String, dynamic> user, ColorScheme colors) {
    // Ambil nama user dengan aman
    String username = user['nama_lengkap'] ?? user['username'] ?? 'User';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER SECTION
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, const Color(0xFF8A7DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, $username",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Selamat datang kembali!",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    // Logout Button
                    GestureDetector(
                      onTap: _isLoggingOut ? null : _logout,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.2 * 255).round()),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _isLoggingOut 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.logout_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Widget Status Parkir Aktif (Panggil Halaman Khusus)
                // Kita bungkus PageTransaksiAktif agar tampil rapi di header
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.white,
                    // Kirim token ke widget status parkir
                    child: PageTransaksiAktif(token: widget.token), 
                  ),
                ),
              ],
            ),
          ),

          // 2. MENU GRID
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Layanan Cepat",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildFeatureCard(
                      "Motor Saya",
                      Icons.motorcycle_rounded,
                      Colors.blue.shade50,
                      Colors.blue,
                      () => setState(() => _selectedIndex = 1),
                    ),
                    _buildFeatureCard(
                      "Membership",
                      Icons.card_membership_rounded,
                      Colors.orange.shade50,
                      Colors.orange,
                      () => setState(() => _selectedIndex = 2),
                    ),
                    _buildFeatureCard(
                      "Riwayat",
                      Icons.history_rounded,
                      Colors.purple.shade50,
                      Colors.purple,
                      () {
                         // Navigasi ke halaman riwayat (jika ada)
                         // Navigator.push(context, MaterialPageRoute(...));
                      },
                    ),
                    _buildFeatureCard(
                      "Bantuan",
                      Icons.support_agent_rounded,
                      Colors.green.shade50,
                      Colors.green,
                      () {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fitur Bantuan segera hadir!")),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Item Navigasi Bawah
  Widget _buildNavItem(int index, IconData icon, String label, Color activeColor) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
          color: isSelected ? activeColor.withAlpha((0.1 * 255).round()) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.grey.shade400,
              size: 26,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Kartu Fitur
  Widget _buildFeatureCard(String title, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}