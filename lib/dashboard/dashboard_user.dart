import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../pages/login_page.dart';

// Import halaman fitur
import 'page_motor_saya.dart';
import 'page_member.dart';
import 'page_pembayaran.dart'; // Bisa diganti PageRiwayat jika lebih cocok
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

  // --- LOGOUT ---
  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    await ApiService.logout(widget.token);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const LoginPage()), 
      (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Background abu-abu muda lembut
      
      // BODY: Mengganti tampilan berdasarkan tab yang dipilih
      body: _buildBodyContent(),

      // BOTTOM NAVIGATION BAR (Custom Floating)
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, "Home"),
            _buildNavItem(1, Icons.two_wheeler_rounded, "Motor"),
            _buildNavItem(2, Icons.card_membership_rounded, "Member"),
            _buildNavItem(3, Icons.history_rounded, "Riwayat"),
          ],
        ),
      ),
    );
  }

  // --- CONTENT SWITCHER ---
  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeUI();
      case 1:
        return PageMotorSaya(token: widget.token, userData: widget.userData);
      case 2:
        return PageMember(token: widget.token, userData: widget.userData);
      case 3:
        return PagePembayaran(token: widget.token); // Atau PageRiwayat
      default:
        return const SizedBox();
    }
  }

  // --- HALAMAN UTAMA (HOME DASHBOARD) ---
  Widget _buildHomeUI() {
    final colorScheme = Theme.of(context).colorScheme;
    String username = widget.userData['nama_lengkap'] ?? widget.userData['username'] ?? 'User';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER (Gradient & Profile)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, const Color(0xFF8A7DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, $username 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Mau parkir di mana hari ini?",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                // Tombol Logout Kecil
                InkWell(
                  onTap: _isLoggingOut ? null : _logout,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isLoggingOut 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.logout, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          ),

          // 2. STATUS PARKIR AKTIF (Overlapping Header)
          Transform.translate(
            offset: const Offset(0, -25), // Geser ke atas sedikit
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label Section
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      "Status Parkir Saat Ini",
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black26)]
                      ),
                    ),
                  ),
                  
                  // Container Widget Status
                  Container(
                    height: 140, // Tinggi fix agar rapi
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    // Memanggil PageTransaksiAktif tapi dibatasi ukurannya
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: PageTransaksiAktif(token: widget.token),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. MENU GRID (Fitur Utama)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Akses Cepat",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMenuCard(
                      "Motor Saya", 
                      Icons.motorcycle_rounded, 
                      Colors.blue, 
                      () => setState(() => _selectedIndex = 1)
                    ),
                    _buildMenuCard(
                      "Membership", 
                      Icons.card_membership_rounded, 
                      Colors.orange, 
                      () => setState(() => _selectedIndex = 2)
                    ),
                    _buildMenuCard(
                      "Riwayat", 
                      Icons.history_rounded, 
                      Colors.purple, 
                      () => setState(() => _selectedIndex = 3)
                    ),
                    _buildMenuCard(
                      "Bantuan", 
                      Icons.support_agent_rounded, 
                      Colors.green, 
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Hubungi CS: 0812-3456-7890"))
                        );
                      }
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Space bawah agar tidak ketutup Nav Bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  // Item Navigasi Bawah
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    Color color = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade400,
              size: 26,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
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

  // Kartu Menu Grid
  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
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