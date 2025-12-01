// lib/pages/admin/dashboard_admin.dart
import 'package:flutter/material.dart';
import '../../widgets/dashboard_tile.dart';
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
  // index untuk memilih halaman/content di kanan
  int _selectedIndex = 0;

  // judul setiap halaman (untuk header kanan)
  final List<String> _pageTitles = [
    "Dashboard",
    "Pengguna",
    "Motor",
    "Pembayaran",
    "Riwayat",
    "Slot Parkir",
    "Pengaturan",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: Text(_pageTitles[_selectedIndex]),
      ),
      body: SafeArea(
        child: Row(
          children: [
            // ====== SIDEBAR KIRI (tiles vertical) ======
            Container(
              width: 260,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Admin",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  // tile vertical -> gunakan Expanded ListView agar bisa scroll jika banyak
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildSidebarTile(
                          icon: Icons.dashboard,
                          title: "Dashboard",
                          index: 0,
                        ),
                        const SizedBox(height: 8),
                        _buildSidebarTile(
                          icon: Icons.people,
                          title: "Pengguna",
                          index: 1,
                        ),
                        const SizedBox(height: 8),
                        _buildSidebarTile(
                          icon: Icons.motorcycle,
                          title: "Motor",
                          index: 2,
                        ),
                        const SizedBox(height: 8),
                        _buildSidebarTile(
                          icon: Icons.payment,
                          title: "Pembayaran",
                          index: 3,
                        ),
                        const SizedBox(height: 8),
                        _buildSidebarTile(
                          icon: Icons.history,
                          title: "Riwayat",
                          index: 4,
                        ),
                        const SizedBox(height: 8),
                        _buildSidebarTile(
                          icon: Icons.local_parking,
                          title: "Slot Parkir",
                          index: 5,
                        ),
                        const SizedBox(height: 8),
                        _buildSidebarTile(
                          icon: Icons.settings,
                          title: "Pengaturan",
                          index: 6,
                        ),
                      ],
                    ),
                  ),

                  // logout atau footer
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: logout action
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            // ====== KONTEN KANAN (utama) ======
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.grey[100],
                child: _buildRightContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar single tile (highlight ketika aktif)
  Widget _buildSidebarTile({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool selected = _selectedIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: Colors.deepPurple.withOpacity(0.2))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.deepPurple : Colors.black54),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.deepPurple : Colors.black87,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // build konten kanan bergantung index
  Widget _buildRightContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardOverview();
      case 1:
        return const PenggunaPage();
      case 2:
        return const MotorPage();
      case 3:
        return const PembayaranPage();
      case 4:
        return const RiwayatPage();
      case 5:
        return const ParkirPage();
      case 6:
        return const PengaturanPage();
      default:
        return const Center(child: Text("Halaman belum tersedia"));
    }
  }

  // ===== DASHBOARD OVERVIEW: stat card + grid tile + tabel =====
  Widget _buildDashboardOverview() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header welcome kecil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Welcome Back 👋",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Row(
                children: const [
                  Icon(Icons.notifications_none),
                  SizedBox(width: 12),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 18),

          // Stat cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: "450 Devices",
                  subtitle: "Total Device Finance",
                  date: "30 April 2022",
                  color1: const Color(0xFFFE5E73),
                  color2: const Color(0xFFF76F83),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: "310 Devices",
                  subtitle: "EMI Collection Pending",
                  date: "30 April 2022",
                  color1: const Color(0xFF8A7DFF),
                  color2: const Color(0xFF695FFE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: "560 Devices",
                  subtitle: "Current Stock",
                  date: "30 April 2022",
                  color1: const Color(0xFFF9C851),
                  color2: const Color(0xFFF7B338),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Grid kecil tile (visual) - gunakan 3 kolom pada layar besar, 2 kolom kalau sempit
          LayoutBuilder(builder: (context, constraints) {
            final int crossAxis = constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 600
                    ? 2
                    : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxis,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3 / 2,
              children: [
                DashboardTile(
                  icon: Icons.people,
                  title: "Pengguna",
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                DashboardTile(
                  icon: Icons.motorcycle,
                  title: "Motor",
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                DashboardTile(
                  icon: Icons.payment,
                  title: "Pembayaran",
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
                DashboardTile(
                  icon: Icons.history,
                  title: "Riwayat",
                  onTap: () => setState(() => _selectedIndex = 4),
                ),
                DashboardTile(
                  icon: Icons.local_parking,
                  title: "Slot Parkir",
                  onTap: () => setState(() => _selectedIndex = 5),
                ),
                DashboardTile(
                  icon: Icons.settings,
                  title: "Pengaturan",
                  onTap: () => setState(() => _selectedIndex = 6),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),

          const Text(
  "Daftar Motor Terbaru",
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
const SizedBox(height: 12),

SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: ConstrainedBox(
    constraints: BoxConstraints(minWidth: 700),
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text("No")),
          DataColumn(label: Text("Pemilik")),
          DataColumn(label: Text("Merk")),
          DataColumn(label: Text("Plat Nomor")),
          DataColumn(label: Text("Status")),
        ],
        rows: List.generate(
          5,
          (index) => DataRow(cells: [
            DataCell(Text("${index + 1}")),
            DataCell(Text("User ${index + 1}")),
            DataCell(Text("Honda Beat")),
            DataCell(Text("B 12${index}3 CD")),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Tersimpan",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
          ]),
        ),
      ),
    ),
  ),
),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Stat card with gradient
  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required String date,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const Spacer(),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(date, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
