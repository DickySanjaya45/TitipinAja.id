import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart'; // Pastikan path benar
import '../../services/api_service.dart'; // Import ApiService
import '../pages/login_page.dart'; // Import Login Page

class PengaturanPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> adminData; // Data user/admin yang login

  const PengaturanPage({
    super.key, 
    required this.token, 
    required this.adminData
  });

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  bool _notifikasiEnabled = true;
  bool _darkModeEnabled = false;

  // --- LOGOUT LOGIC ---
  Future<void> _handleLogout() async {
    // Tampilkan konfirmasi dialog
    bool confirm = await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    ) ?? false;

    if (confirm) {
      // Panggil API Logout
      await ApiService.logout(widget.token);
      
      if (!mounted) return;
      // Kembali ke Login
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const LoginPage()), 
        (route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data profil
    String nama = widget.adminData['nama_petugas'] ?? widget.adminData['nama'] ?? 'User';
    String email = widget.adminData['email'] ?? '-';
    String role = widget.adminData['role'] ?? 'Admin'; // Atau shift_kerja

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomAppBar(title: 'Pengaturan'),
      
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. KARTU PROFIL
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.05 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
                  child: Text(
                    nama[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Theme.of(context).primaryColor
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(email, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: Text(role, style: const TextStyle(fontSize: 12, color: Colors.blue)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text("Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),

          // 2. MENU AKUN
          _buildMenuCard([
            _buildListTile(Icons.person_outline, "Edit Profil", () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Edit Profil segera hadir")));
            }),
            _buildDivider(),
            _buildListTile(Icons.lock_outline, "Ganti Password", () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Ganti Password segera hadir")));
            }),
          ]),

          const SizedBox(height: 24),
          const Text("Aplikasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),

          // 3. MENU APLIKASI (Switch)
          _buildMenuCard([
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined, color: Colors.deepPurple),
              title: const Text("Notifikasi", style: TextStyle(fontWeight: FontWeight.w500)),
              value: _notifikasiEnabled,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (val) => setState(() => _notifikasiEnabled = val),
            ),
            _buildDivider(),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined, color: Colors.deepPurple),
              title: const Text("Mode Gelap", style: TextStyle(fontWeight: FontWeight.w500)),
              value: _darkModeEnabled,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (val) => setState(() => _darkModeEnabled = val),
            ),
          ]),

          const SizedBox(height: 30),

          // 4. TOMBOL LOGOUT
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          
          const SizedBox(height: 20),
          const Center(
            child: Text("Versi Aplikasi 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}