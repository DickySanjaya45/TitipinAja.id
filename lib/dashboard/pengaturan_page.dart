import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../../services/api_service.dart';
import '../pages/login_page.dart';

class PengaturanPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> adminData;

  const PengaturanPage({
    super.key,
    required this.token,
    required this.adminData,
  });

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  bool _notifEnabled = true;
  bool _darkMode = false;

  // --- GETTERS (Agar kode build lebih bersih) ---
  String get _name => widget.adminData['nama_petugas'] ?? widget.adminData['nama'] ?? 'Admin';
  String get _email => widget.adminData['email'] ?? '-';
  String get _role => widget.adminData['shift_kerja'] ?? widget.adminData['role'] ?? 'Petugas';

  // --- LOGIC ---
  Future<void> _handleLogout() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Yakin ingin keluar aplikasi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await ApiService.logout(widget.token);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // --- MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomAppBar(title: 'Pengaturan'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Profil Section
          _ProfileCard(name: _name, email: _email, role: _role),
          
          const SizedBox(height: 24),
          const _SectionLabel("Akun"),
          
          // 2. Menu Akun
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.person_outline, 
              title: "Edit Profil", 
              onTap: () => _showSnack("Fitur Edit Profil segera hadir")
            ),
            const _Divider(),
            _SettingsTile(
              icon: Icons.lock_outline, 
              title: "Ganti Password", 
              onTap: () => _showSnack("Fitur Ganti Password segera hadir")
            ),
          ]),

          const SizedBox(height: 24),
          const _SectionLabel("Aplikasi"),

          // 3. Menu Aplikasi
          _SettingsGroup(children: [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined, color: Colors.deepPurple),
              title: const Text("Notifikasi", style: TextStyle(fontWeight: FontWeight.w500)),
              value: _notifEnabled,
              activeColor: Colors.deepPurple,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: (val) => setState(() => _notifEnabled = val),
            ),
            const _Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined, color: Colors.deepPurple),
              title: const Text("Mode Gelap", style: TextStyle(fontWeight: FontWeight.w500)),
              value: _darkMode,
              activeColor: Colors.deepPurple,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: (val) => setState(() => _darkMode = val),
            ),
          ]),

          const SizedBox(height: 30),
          
          // 4. Logout
          _LogoutButton(onPressed: _handleLogout),
          
          const SizedBox(height: 20),
          const Center(
            child: Text("Versi 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
  }
}

// ===============================================================
// 🧩 WIDGET COMPONENTS (Modular & Ringan)
// ===============================================================

class _ProfileCard extends StatelessWidget {
  final String name, email, role;
  const _ProfileCard({required this.name, required this.email, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepPurple.withOpacity(0.1),
            child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(role, style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}