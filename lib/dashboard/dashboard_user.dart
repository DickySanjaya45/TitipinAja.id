import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../pages/login_page.dart';

// Import halaman fitur
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
  bool _isLoggingOut = false;

  // --- LOGIC ---

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    await ApiService.logout(widget.token);
    
    if (!mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  String get _username => 
      widget.userData['nama_lengkap'] ?? widget.userData['username'] ?? 'User';

  // --- CONTENT BUILDER ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _buildBody(),
      bottomNavigationBar: _CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildHome();
      case 1: return PageMotorSaya(token: widget.token, userData: widget.userData);
      case 2: return PageMember(token: widget.token, userData: widget.userData);
      case 3: return PagePembayaran(token: widget.token);
      default: return const SizedBox();
    }
  }

  // --- HOME UI SECTIONS ---

  Widget _buildHome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(
            username: _username, 
            onLogout: _logout, 
            isLoggingOut: _isLoggingOut
          ),
          _ParkingStatusSection(token: widget.token),
          _MenuGridSection(onMenuTap: _onItemTapped),
        ],
      ),
    );
  }
}

// ===============================================================
// 🧩 WIDGET COMPONENTS (Extracted for better performance & clean code)
// ===============================================================

class _HeaderSection extends StatelessWidget {
  final String username;
  final VoidCallback onLogout;
  final bool isLoggingOut;

  const _HeaderSection({
    required this.username,
    required this.onLogout,
    required this.isLoggingOut,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, const Color(0xFF8A7DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
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
          InkWell(
            onTap: isLoggingOut ? null : onLogout,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoggingOut
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.logout, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParkingStatusSection extends StatelessWidget {
  final String token;
  const _ParkingStatusSection({required this.token});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                "Status Parkir Saat Ini",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
                ),
              ),
            ),
            Container(
              height: 140,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: PageTransaksiAktif(token: token),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuGridSection extends StatelessWidget {
  final Function(int) onMenuTap;

  const _MenuGridSection({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    // Data Menu (Agar kodingan GridView bersih)
    final List<Map<String, dynamic>> menuItems = [
      {'title': "Motor Saya", 'icon': Icons.motorcycle_rounded, 'color': Colors.blue, 'index': 1},
      {'title': "Membership", 'icon': Icons.card_membership_rounded, 'color': Colors.orange, 'index': 2},
      {'title': "Riwayat", 'icon': Icons.history_rounded, 'color': Colors.purple, 'index': 3},
      {'title': "Bantuan", 'icon': Icons.support_agent_rounded, 'color': Colors.green, 'action': 'snackbar'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Akses Cepat",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _MenuCard(
                title: item['title'],
                icon: item['icon'],
                color: item['color'],
                onTap: () {
                  if (item['action'] == 'snackbar') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Hubungi CS: 0812-3456-7890")),
                    );
                  } else {
                    onMenuTap(item['index']);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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

class _CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _CustomBottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;

    return Container(
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
          _NavBarItem(index: 0, icon: Icons.home_rounded, label: "Home", isSelected: selectedIndex == 0, color: color, onTap: onTap),
          _NavBarItem(index: 1, icon: Icons.two_wheeler_rounded, label: "Motor", isSelected: selectedIndex == 1, color: color, onTap: onTap),
          _NavBarItem(index: 2, icon: Icons.card_membership_rounded, label: "Member", isSelected: selectedIndex == 2, color: color, onTap: onTap),
          _NavBarItem(index: 3, icon: Icons.history_rounded, label: "Riwayat", isSelected: selectedIndex == 3, color: color, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final Function(int) onTap;

  const _NavBarItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey.shade400, size: 26),
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
}