import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // jika layar besar (desktop/tablet)
          if (constraints.maxWidth > 700) {
            return Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildMainContent(context)),
              ],
            );
          }

          // jika layar kecil (mobile)
          return _buildMainContent(context);
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 700
          ? _buildBottomNav()
          : null,
    );
  }

  // ==============================
  // SIDEBAR (untuk laptop/tablet)
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
          _buildSidebarItem(Icons.logout, "Logout"),
        ],
      ),
    );
  }

  // ==============================
  // KONTEN DASHBOARD
  // ==============================
  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _menuTitles[_selectedIndex],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Selamat datang kembali, Admin!",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text("AD", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // STATISTIC CARDS (hanya di dashboard utama)
          if (_selectedIndex == 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatCard(color: Color(0xFFFFD54F), value: "83%", label: "Kapasitas Parkir"),
                _StatCard(color: Color(0xFF9575CD), value: "77%", label: "Tingkat Penggunaan"),
                _StatCard(color: Color(0xFFF48FB1), value: "91", label: "Transaksi Hari Ini"),
                _StatCard(color: Color(0xFFCE93D8), value: "126", label: "Total Motor"),
              ],
            ),

          const SizedBox(height: 32),

          // LIST AKTIVITAS
          const Text(
            "Aktivitas Terbaru",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                _ActivityItem(
                  title: "Motor B 1234 ABC Masuk",
                  subtitle: "Jam 08:20 WIB - Difvo Erza",
                  color: Colors.green,
                ),
                _ActivityItem(
                  title: "Pembayaran Selesai",
                  subtitle: "Rp 10.000 - Dita Titania",
                  color: Colors.blue,
                ),
                _ActivityItem(
                  title: "Motor B 7777 ZZ Keluar",
                  subtitle: "Jam 09:15 WIB - Alfina Berlian",
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildSidebarItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}

// daftar ikon untuk setiap menu
final List<IconData> _menuIcons = [
  Icons.dashboard,
  Icons.people,
  Icons.motorcycle,
  Icons.payment,
  Icons.history,
  Icons.local_parking,
  Icons.settings,
];

// ======================================================
// Widget: Statistik Card
// ======================================================
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

// ======================================================
// Widget: Aktivitas Terbaru
// ======================================================
class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
