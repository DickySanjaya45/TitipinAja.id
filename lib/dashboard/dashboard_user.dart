import 'package:flutter/material.dart';
import 'page_motor_saya.dart';
import 'page_member.dart';
import 'page_pembayaran.dart';
import 'page_transaksi_aktif.dart';

class DashboardUser extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String token;

  const DashboardUser({super.key, required this.userData, required this.token});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    PageTransaksiAktif(),
    PageMotorSaya(),
    PageMember(),
    PagePembayaran(),
  ];

  @override
  Widget build(BuildContext context) {
    // Warna dari tema
    final colorScheme = Theme.of(context).colorScheme;
    final username = widget.userData['username'] ?? 'User';

    return Scaffold(
      // Body dengan content changer
      body: _selectedIndex == 0
          ? _buildHomeUI(username, colorScheme) // Home Custom UI
          : _pages[_selectedIndex - 1], // Halaman Menu Lain
      // Custom Floating Bottom Navigation
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
            _buildNavItem(0, Icons.home_rounded, "Home", colorScheme.primary),
            _buildNavItem(
              1,
              Icons.two_wheeler_rounded,
              "Motor",
              colorScheme.primary,
            ),
            _buildNavItem(
              2,
              Icons.card_membership_rounded,
              "Member",
              colorScheme.primary,
            ),
            _buildNavItem(
              3,
              Icons.account_balance_wallet_rounded,
              "Bayar",
              colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  // UI Khusus Halaman Utama Dashboard
  Widget _buildHomeUI(String username, ColorScheme colors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER SECTION (Gradient & Info)
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
                    // Profile / Logout Button
                    GestureDetector(
                      onTap: _logout,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Status Card (Floating)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5FAFB),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.local_parking,
                          color: Color(0xFF00C897),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Status Kendaraan",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Honda Vario 125",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Slot A-12 • Masuk 08:00 WIB",
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                      () {}, // Tambahkan navigasi
                    ),
                    _buildFeatureCard(
                      "Bantuan",
                      Icons.support_agent_rounded,
                      Colors.green.shade50,
                      Colors.green,
                      () {},
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

  // Helper Widget: Item Navigasi Bawah dengan Animasi
  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
  ) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
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

  // Helper Widget: Kartu Fitur di Home
  Widget _buildFeatureCard(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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

  void _logout() {
    // Logika logout
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/login');
  }
}
