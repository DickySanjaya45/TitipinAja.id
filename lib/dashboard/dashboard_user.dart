import 'package:flutter/material.dart';
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
    required this.token,
  });

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  int _selectedIndex = 0;

  final List<String> _menuTitles = [
    "Motor Saya",
    "Member",
    "Pembayaran",
    "Transaksi Aktif",
  ];

  final List<IconData> _menuIcons = [
    Icons.motorcycle,
    Icons.card_membership,
    Icons.payment,
    Icons.receipt_long,
  ];

  final List<Widget> _pages = const [
    PageMotorSaya(),
    PageMember(),
    PagePembayaran(),
    PageTransaksiAktif(),
  ];

  // ==============================
  // LOGOUT
  // ==============================
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Logout"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),

      // ==============================
      // RESPONSIVE: SIDEBAR JIKA DI LAYAR LEBAR
      // ==============================
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 700) {
            return Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildMainContent()),
              ],
            );
          }
          return _buildMainContent();
        },
      ),

      // Bottom nav untuk HP
      bottomNavigationBar: MediaQuery.of(context).size.width < 700
          ? _buildBottomNav()
          : null,
    );
  }

  // ==============================
  // SIDEBAR USER
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
            "TitipinAja.id",   // 👈 SUDAH AKU TAMBAHKAN DI SINI
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),

          ...List.generate(_menuTitles.length, (index) {
            bool selected = index == _selectedIndex;

            return InkWell(
              onTap: () => setState(() => _selectedIndex = index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.deepPurple.shade400 : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(_menuIcons[index], color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      _menuTitles[index],
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    )
                  ],
                ),
              ),
            );
          }),

          const Spacer(),

          // Logout
          InkWell(
            onTap: _logout,
            child: Row(
              children: const [
                Icon(Icons.logout, color: Colors.white),
                SizedBox(width: 12),
                Text("Logout", style: TextStyle(color: Colors.white)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==============================
  // MAIN CONTENT
  // ==============================
  Widget _buildMainContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _pages[_selectedIndex],
    );
  }

  // ==============================
  // BOTTOM NAV HP
  // ==============================
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      onTap: (i) => setState(() => _selectedIndex = i),
      items: List.generate(_menuTitles.length, (i) {
        return BottomNavigationBarItem(
          icon: Icon(_menuIcons[i]),
          label: _menuTitles[i],
        );
      }),
    );
  }
}
