import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart'; // Pastikan widget ini ada
import '../../services/api_service.dart'; // Import ApiService

class PenggunaPage extends StatefulWidget {
  final String token; // Token wajib diterima dari Dashboard

  const PenggunaPage({super.key, required this.token});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  // Variabel State
  List<dynamic> _daftarPengguna = [];
  bool _isLoading = true;

  // Controller Form
  final _namaLengkapController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noTeleponController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPengguna(); // Ambil data saat halaman dibuka
  }

  // --- 1. GET DATA (READ via ApiService) ---
  Future<void> _fetchPengguna() async {
    setState(() => _isLoading = true);
    
    try {
      // Panggil fungsi dari ApiService
      final data = await ApiService.getPengguna(widget.token);
      
      setState(() {
        _daftarPengguna = data; 
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Gagal memuat data: $e');
      setState(() => _isLoading = false);
    }
  }

  // --- 2. POST DATA (CREATE via ApiService) ---
  Future<void> _simpanPengguna() async {
    // Siapkan data
    Map<String, dynamic> data = {
      'nama_lengkap': _namaLengkapController.text,
      'alamat': _alamatController.text,
      'no_telepon': _noTeleponController.text,
      'email': _emailController.text,
      'password': _passwordController.text, // Wajib
    };

    try {
      final response = await ApiService.createPengguna(widget.token, data);
      if (!mounted) return;

      if (response['success'] == true) {
        _showSnackBar('Pengguna berhasil ditambahkan');
        Navigator.pop(context); // Tutup dialog
        _clearControllers();
        _fetchPengguna(); // Refresh list
      } else {
        _showSnackBar('Gagal: ${response['message']}');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: $e');
    }
  }

  // --- 3. PUT DATA (UPDATE via ApiService) ---
  Future<void> _updatePengguna(int id) async {
    // Siapkan data update
    Map<String, dynamic> data = {
      'nama_lengkap': _namaLengkapController.text,
      'alamat': _alamatController.text,
      'no_telepon': _noTeleponController.text,
      'email': _emailController.text,
    };

    // Password hanya dikirim jika diisi
    if (_passwordController.text.isNotEmpty) {
      data['password'] = _passwordController.text;
    }

    try {
      final response = await ApiService.updatePengguna(id, widget.token, data);
      if (!mounted) return;

      if (response['success'] == true) {
        _showSnackBar('Pengguna berhasil diperbarui');
        Navigator.pop(context);
        _clearControllers();
        _fetchPengguna();
      } else {
        _showSnackBar('Gagal update: ${response['message']}');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: $e');
    }
  }

  // --- 4. DELETE DATA (via ApiService) ---
  Future<void> _hapusPenggunaAPI(int id) async {
    try {
      final response = await ApiService.deletePengguna(id, widget.token);
      if (!mounted) return;

      if (response['success'] == true) {
        _showSnackBar('Pengguna berhasil dihapus');
        Navigator.pop(context); 
        _fetchPengguna(); 
      } else {
        _showSnackBar('Gagal menghapus: ${response['message']}');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: $e');
    }
  }

  // --- HELPER FUNCTIONS ---
  void _clearControllers() {
    _namaLengkapController.clear();
    _alamatController.clear();
    _noTeleponController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- UI DIALOGS ---
  void _showFormDialog({Map<String, dynamic>? pengguna}) {
    bool isEdit = pengguna != null;
    
    if (isEdit) {
      _namaLengkapController.text = pengguna['nama_lengkap'] ?? '';
      _alamatController.text = pengguna['alamat'] ?? '';
      _noTeleponController.text = pengguna['no_telepon'] ?? '';
      _emailController.text = pengguna['email'] ?? '';
      _passwordController.clear();
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Pengguna' : 'Tambah Pengguna'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaLengkapController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              TextField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                maxLines: 2,
              ),
              TextField(
                controller: _noTeleponController,
                decoration: const InputDecoration(labelText: 'No. Telepon'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: isEdit ? 'Password (Kosongkan jika tetap)' : 'Password',
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (isEdit) {
                // Pastikan key ID sesuai database (id_pengguna)
                int id = pengguna['id_pengguna'] ?? pengguna['id'];
                _updatePengguna(id); 
              } else {
                _simpanPengguna();
              }
            },
            child: Text(isEdit ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> pengguna) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text('Yakin ingin menghapus "${pengguna['nama_lengkap']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              int id = pengguna['id_pengguna'] ?? pengguna['id'];
              _hapusPenggunaAPI(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _lihatDetail(Map<String, dynamic> pengguna) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pengguna['nama_lengkap'] ?? 'Detail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${pengguna['id_pengguna'] ?? pengguna['id']}'),
            const SizedBox(height: 5),
            Text('Email: ${pengguna['email']}'),
            const SizedBox(height: 5),
            Text('No. Telp: ${pengguna['no_telepon']}'),
            const SizedBox(height: 5),
            Text('Alamat: ${pengguna['alamat']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pastikan Anda punya widget CustomAppBar, kalau tidak ganti AppBar biasa
      appBar: const CustomAppBar(title: 'Data Pengguna'),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _daftarPengguna.isEmpty
              ? const Center(child: Text('Belum ada data pengguna'))
              : ListView.builder(
                  itemCount: _daftarPengguna.length,
                  itemBuilder: (context, index) {
                    final pengguna = _daftarPengguna[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text((pengguna['nama_lengkap']?[0] ?? '?').toUpperCase()),
                        ),
                        title: Text(pengguna['nama_lengkap'] ?? '-'),
                        subtitle: Text('${pengguna['email']}'),
                        onTap: () => _lihatDetail(pengguna),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showFormDialog(pengguna: pengguna),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(pengguna),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}