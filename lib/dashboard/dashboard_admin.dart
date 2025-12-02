import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    // Responsive Layout
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // === SIDEBAR ===
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                // Logo Area
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.admin_panel_settings, size: 40, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Admin Panel",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                // Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildMenuItem(0, "Dashboard", Icons.dashboard_outlined),
                      _buildMenuItem(1, "Pengguna", Icons.people_outline),
                      _buildMenuItem(2, "Motor", Icons.motorcycle_outlined),
                      _buildMenuItem(3, "Pembayaran", Icons.payment_outlined),
                      _buildMenuItem(4, "Riwayat", Icons.history_outlined),
                      _buildMenuItem(5, "Slot Parkir", Icons.local_parking_outlined),
                      const Divider(height: 40),
                      _buildMenuItem(6, "Pengaturan", Icons.settings_outlined),
                    ],
                  ),
                ),

                // Logout
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: InkWell(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // === MAIN CONTENT ===
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    final color = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => setState(() => _selectedIndex = index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? color : Colors.transparent,
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return const Center(child: Text("Welcome to Admin Dashboard", style: TextStyle(fontSize: 20, color: Colors.grey))); // Placeholder for dashboard Home
      case 1: return const PenggunaPage();
      case 2: return const MotorPage();
      case 3: return const PembayaranPage();
      case 4: return const RiwayatPage();
      case 5: return const ParkirPage();
      case 6: return const PengaturanPage();
      default: return const SizedBox();
    }
  }
}