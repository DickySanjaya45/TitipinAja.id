import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../login_page.dart';
import 'pengguna_page.dart';
import 'motor_page.dart';
import 'pembayaran_page.dart';
import 'riwayat_page.dart';
import 'parkir_page.dart';
import 'pengaturan_page.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _selectedIndex = 0;

  final List<String> _menuTitles = [
    "Dashboard",
    "Pengguna",
    "Motor",
    "Pembayaran",
    "Riwayat",
    "Slot Parkir",
    "Pengaturan"
  ];

  final List<IconData> _menuIcons = [
    Icons.dashboard,
    Icons.people,
    Icons.motorcycle,
    Icons.payment,
    Icons.history,
    Icons.local_parking,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 700) {
            return Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildMainContent()),
              ],
            );
          } else {
            return _buildMainContent();
          }
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 700
          ? _buildBottomNav()
          : null,
    );
  }

  // ==============================
  // SIDEBAR
  // ==============================
  Widget _buildSidebar() {
    return Container(
      width: 220,
      color: Colors.deepPurple.shade700,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TitipinAja.id",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          ...List.generate(_menuTitles.length, (index) {
            final title = _menuTitles[index];
            final icon = _menuIcons[index];
            final isSelected = _selectedIndex == index;

            return InkWell(
              onTap: () => setState(() => _selectedIndex = index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.deepPurple.shade400
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          _buildSidebarItem(Icons.logout, "Logout", onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }),
        ],
      ),
    );
  }

  // ==============================
  // KONTEN UTAMA (BERUBAH SESUAI MENU)
  // ==============================
  Widget _buildMainContent() {
    Widget content;

    switch (_selectedIndex) {
      case 0:
        content = const DashboardHome();
        break;
      case 1:
        content = const PenggunaPage();
        break;
      case 2:
        content = const MotorPage();
        break;
      case 3:
        content = const PembayaranPage();
        break;
      case 4:
        content = const RiwayatPage();
        break;
      case 5:
        content = const ParkirPage();
        break;
      case 6:
        content = const PengaturanPage();
        break;
      default:
        content = const Center(child: Text("Halaman tidak ditemukan"));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: content,
    );
  }

  // ==============================
  // BOTTOM NAV UNTUK MOBILE
  // ==============================
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: List.generate(_menuTitles.length, (i) {
        return BottomNavigationBarItem(
          icon: Icon(_menuIcons[i]),
          label: _menuTitles[i],
        );
      }),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ==============================
// DASHBOARD HOME DEFAULT
// ==============================
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Dashboard Admin"),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selamat datang kembali, Admin!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatCard(color: Color(0xFFFFD54F), value: "83%", label: "Kapasitas Parkir"),
                _StatCard(color: Color(0xFF9575CD), value: "77%", label: "Tingkat Penggunaan"),
                _StatCard(color: Color(0xFFF48FB1), value: "91", label: "Transaksi Hari Ini"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
