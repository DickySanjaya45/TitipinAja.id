import 'package:flutter/material.dart';
import '../login_page.dart';
import '../services/api_service.dart'; // Pastikan Anda mengimpor ApiService
// import 'dart:convert'; // Tidak digunakan di file ini

class DashboardUser extends StatefulWidget {
  // Kita perlu data pengguna & token yang didapat dari halaman login
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
  int _selectedIndex = 0; // 0: Dashboard, 1: Motor, ..., 4: Profil

  // Daftar halaman/widget yang akan ditampilkan
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar halaman
    _pages = [
      _DashboardContent(
          namaPengguna: widget.userData['nama_lengkap'] ?? 'User',
          token: widget.token), // <-- Mengirimkan token ke _DashboardContent
      _PlaceholderPage(title: 'Motor'), // Halaman Motor (placeholder)
      _PlaceholderPage(title: 'Pembayaran'), // Halaman Pembayaran (placeholder)
      _PlaceholderPage(title: 'Riwayat'), // Halaman Riwayat (placeholder)
      // Halaman Profil untuk Edit/Delete
      _ProfilePageWidget(userData: widget.userData, token: widget.token),
    ];
  }

  void _onMenuItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    // Panggil API Logout (jika ada)
    try {
      // Kita asumsikan ada fungsi logout di ApiService
      await ApiService.logout(widget.token);
    } catch (e) {
      // Tetap logout dari sisi client meskipun API gagal
      print("Error saat logout API: $e");
    }

    // Pastikan widget masih mounted sebelum menggunakan context
    if (!mounted) return;

    // Kembali ke halaman Login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: const Color(0xFF5B2B9C),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "TitipinAja.id",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildMenuItem(Icons.dashboard, "Dashboard", 0,
                    onTap: () => _onMenuItemTapped(0)),
                _buildMenuItem(Icons.motorcycle, "Motor", 1,
                    onTap: () => _onMenuItemTapped(1)),
                _buildMenuItem(Icons.payment, "Pembayaran", 2,
                    onTap: () => _onMenuItemTapped(2)),
                _buildMenuItem(Icons.history, "Riwayat", 3,
                    onTap: () => _onMenuItemTapped(3)),
                _buildMenuItem(Icons.person, "Profil Saya", 4, // Tombol baru
                    onTap: () => _onMenuItemTapped(4)),
                const Spacer(),
                _buildMenuItem(Icons.logout, "Logout", 99, onTap: _logout),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Konten utama
          Expanded(
            child: Container(
              color: const Color(0xFFF8F6FF),
              // Tampilkan halaman berdasarkan _selectedIndex
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index,
      {VoidCallback? onTap}) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- KONTEN DASHBOARD (SEKARANG STATEFUL UNTUK READ DATA) ---
class _DashboardContent extends StatefulWidget {
  final String namaPengguna;
  final String token; // <-- Menerima token
  const _DashboardContent({required this.namaPengguna, required this.token});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  late Future<List<dynamic>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    // Memulai proses READ data saat widget ini dibuat
    _activitiesFuture = _fetchActivities();
  }

  Future<List<dynamic>> _fetchActivities() async {
    try {
      // Memanggil fungsi API baru yang akan kita buat
      final result = await ApiService.getActivities(widget.token);
      if (result['success'] == true && result['data'] is List) {
        return result['data'];
      } else {
        throw Exception(result['message'] ?? 'Gagal memuat data aktivitas');
      }
    } catch (e) {
      // Menangani error jika terjadi
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Pengguna",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Selamat datang kembali, ${widget.namaPengguna}!",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          const Text(
            "Aktivitas Terbaru",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          // Menggunakan FutureBuilder untuk menampilkan data READ
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _activitiesFuture,
              builder: (context, snapshot) {
                // Tampilkan loading spinner
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Tampilkan pesan error
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Gagal memuat aktivitas: ${snapshot.error}'));
                }

                // Tampilkan jika tidak ada data
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada aktivitas terbaru.'));
                }

                // Jika data ada, tampilkan
                final activities = snapshot.data!;

                return ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index] as Map<String, dynamic>;
                    
                    // Asumsi API mengembalikan 'tipe', 'deskripsi', dan 'waktu'
                    Color color = Colors.grey;
                    if (activity['tipe'] == 'masuk') color = Colors.green;
                    if (activity['tipe'] == 'keluar') color = Colors.red;
                    if (activity['tipe'] == 'bayar') color = Colors.blue;

                    return _buildActivityCard(
                      color: color,
                      title: activity['deskripsi'] ?? 'Aktivitas tidak diketahui',
                      subtitle: activity['waktu'] ?? '',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget card aktivitas (dipindahkan ke sini)
  Widget _buildActivityCard(
      {required Color color,
      required String title,
      required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(30, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

// --- WIDGET PROFIL BARU UNTUK EDIT & DELETE ---
class _ProfilePageWidget extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String token;

  const _ProfilePageWidget(
      {required this.userData, required this.token});

  @override
  State<_ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<_ProfilePageWidget> {
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _teleponController;
  late TextEditingController _alamatController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data pengguna saat ini
    // === PERBAIKAN: Gunakan 'id_pengguna' ===
    _namaController =
        TextEditingController(text: widget.userData['nama_lengkap']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _teleponController =
        TextEditingController(text: widget.userData['no_telepon']);
    _alamatController = TextEditingController(text: widget.userData['alamat']);
  }

  Future<void> _saveProfile() async {
    // Validasi dasar
    if (_namaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _teleponController.text.isEmpty ||
        _alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    // Validasi password jika diisi
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konfirmasi password tidak cocok')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Siapkan data untuk dikirim ke API
      Map<String, String> data = {
        'nama_lengkap': _namaController.text,
        'email': _emailController.text,
        'no_telepon': _teleponController.text,
        'alamat': _alamatController.text,
      };

      // Hanya tambahkan password jika diisi
      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      // Dukung beberapa variasi kunci 'id' dari backend: 'id' atau 'id_pengguna'
      dynamic userId = widget.userData['id'] ?? widget.userData['id_pengguna'];

      // Jika userId berupa String, coba parse ke int
      if (userId is String) {
        final parsed = int.tryParse(userId);
        if (parsed != null) {
          userId = parsed;
        }
      }

      // Cek jika userId null atau bukan int
      if (userId == null || userId is! int) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('ID Pengguna tidak valid.')));
        }
        setState(() => _isLoading = false);
        return;
      }
      // ===================================================

      // Panggil API Update (kita asumsikan ada di ApiService)
      // Ini memanggil: PUT /api/pengguna/{id}
      final result =
          await ApiService.updateUser(userId, widget.token, data);
      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui')));
        
        // Perbarui data di controllers setelah update berhasil
        final updatedData = result['data'];
        setState(() {
          _namaController.text = updatedData['nama_lengkap'];
          _emailController.text = updatedData['email'];
          _teleponController.text = updatedData['no_telepon'];
          _alamatController.text = updatedData['alamat'];
        });

  } else {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result['message'] ?? 'Gagal update')));
  }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    // Tampilkan dialog konfirmasi
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus akun Anda? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return; // Batal jika tidak dikonfirmasi
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Dukung beberapa variasi kunci 'id' dari backend: 'id' atau 'id_pengguna'
      dynamic userId = widget.userData['id'] ?? widget.userData['id_pengguna'];

      // Jika userId berupa String, coba parse ke int
      if (userId is String) {
        final parsed = int.tryParse(userId);
        if (parsed != null) userId = parsed;
      }

      // Cek jika userId null atau bukan int
      if (userId == null || userId is! int) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('ID Pengguna tidak valid.')));
        }
        setState(() => _isLoading = false);
        return;
      }

      // Panggil API Delete (kita asumsikan ada di ApiService)
      // Ini memanggil: DELETE /api/pengguna/{id}
      final result = await ApiService.deleteUser(userId, widget.token);
      if (!mounted) return;

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Akun berhasil dihapus')));
        }
        // Logout dan kembali ke login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Gagal hapus akun')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      // Hanya set false jika masih di halaman (belum di-pop)
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profil Saya",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Perbarui data diri atau hapus akun Anda.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Form
            _buildTextField(_namaController, 'Nama Lengkap'),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Email'),
            const SizedBox(height: 16),
            _buildTextField(_teleponController, 'No. Telepon'),
            const SizedBox(height: 16),
            _buildTextField(_alamatController, 'Alamat'),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Ubah Password (Opsional)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildTextField(_passwordController, 'Password Baru', obscure: true),
            const SizedBox(height: 16),
            _buildTextField(_passwordConfirmController, 'Konfirmasi Password Baru',
                obscure: true),
            const SizedBox(height: 30),

            // Tombol Aksi
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Perubahan',
                          style: TextStyle(color: Colors.white)),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _deleteAccount,
                  child: const Text('Hapus Akun',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// --- WIDGET PLACEHOLDER UNTUK MENU LAIN ---
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }
}

