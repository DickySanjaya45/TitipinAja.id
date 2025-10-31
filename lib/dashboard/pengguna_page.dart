import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart'; // Pastikan widget ini tersedia

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  // Data dummy pengguna - DISESUAIKAN DENGAN SKEMA ERD
  List<Map<String, dynamic>> daftarPengguna = [
    {
      'id_pengguna': 1,
      'nama_lengkap': 'Alfina Berlian',
      'alamat': 'Jl. Kenanga No. 12, Jakarta',
      'no_telepon': '081234567890',
      'email': 'alfina@gmail.com',
      'password': 'hashed_password_1', // Field password ditambahkan
    },
    {
      'id_pengguna': 2,
      'nama_lengkap': 'Dicky Sanjaya',
      'alamat': 'Jl. Mawar No. 5, Bandung',
      'no_telepon': '085098765432',
      'email': 'dicky@gmail.com',
      'password': 'hashed_password_2',
    },
    {
      'id_pengguna': 3,
      'nama_lengkap': 'Difvo Erza',
      'alamat': 'Perumahan Indah Blok C, Surabaya',
      'no_telepon': '087112233445',
      'email': 'difvo@gmail.com',
      'password': 'hashed_password_3',
    },
  ];

  // Controller form - DISESUAIKAN DENGAN FIELD ERD
  final _namaLengkapController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noTeleponController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Fungsi untuk mengosongkan controller
  void _clearControllers() {
    _namaLengkapController.clear();
    _alamatController.clear();
    _noTeleponController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  // Tambah pengguna baru - FORM DISESUAIKAN DENGAN FIELD ERD
  void _tambahPengguna() {
    _clearControllers();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pengguna Baru'),
        content: SingleChildScrollView( // Menggunakan SingleChildScrollView untuk mencegah overflow
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
                keyboardType: TextInputType.multiline,
                maxLines: 3,
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
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true, // Untuk keamanan input password
              ),
              // Field 'Role' dihilangkan
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validasi dasar
              if (_namaLengkapController.text.isNotEmpty && _emailController.text.isNotEmpty) {
                setState(() {
                  daftarPengguna.add({
                    'id_pengguna': DateTime.now().millisecondsSinceEpoch,
                    'nama_lengkap': _namaLengkapController.text,
                    'alamat': _alamatController.text,
                    'no_telepon': _noTeleponController.text,
                    'email': _emailController.text,
                    'password': _passwordController.text,
                  });
                });
                _clearControllers();
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Edit pengguna - FORM DISESUAIKAN DENGAN FIELD ERD
  void _editPengguna(int index) {
    final pengguna = daftarPengguna[index];
    // Memuat data yang ada ke controller
    _namaLengkapController.text = pengguna['nama_lengkap'];
    _alamatController.text = pengguna['alamat'];
    _noTeleponController.text = pengguna['no_telepon'];
    _emailController.text = pengguna['email'];
    _passwordController.text = pengguna['password'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pengguna'),
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
                keyboardType: TextInputType.multiline,
                maxLines: 3,
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
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                daftarPengguna[index] = {
                  'id_pengguna': pengguna['id_pengguna'],
                  'nama_lengkap': _namaLengkapController.text,
                  'alamat': _alamatController.text,
                  'no_telepon': _noTeleponController.text,
                  'email': _emailController.text,
                  'password': _passwordController.text,
                };
              });
              _clearControllers();
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Hapus pengguna - DISESUAIKAN DENGAN nama_lengkap
  void _hapusPengguna(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text(
          'Yakin ingin menghapus pengguna "${daftarPengguna[index]['nama_lengkap']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                daftarPengguna.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Detail pengguna (opsional) - DISESUAIKAN UNTUK MENAMPILKAN SEMUA FIELD KECUALI PASSWORD
  void _lihatDetail(Map<String, dynamic> pengguna) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pengguna['nama_lengkap']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID Pengguna: ${pengguna['id_pengguna']}'),
            const SizedBox(height: 5),
            Text('Email: ${pengguna['email']}'),
            const SizedBox(height: 5),
            Text('No. Telepon: ${pengguna['no_telepon']}'),
            const SizedBox(height: 5),
            Text('Alamat: ${pengguna['alamat']}'),
            const SizedBox(height: 5),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Data Pengguna'),
      body: daftarPengguna.isEmpty
          ? const Center(child: Text('Belum ada data pengguna'))
          : ListView.builder(
              itemCount: daftarPengguna.length,
              itemBuilder: (context, index) {
                final pengguna = daftarPengguna[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    // Tampilan utama menggunakan nama_lengkap, email, dan no_telepon
                    title: Text(pengguna['nama_lengkap']),
                    subtitle: Text('${pengguna['email']} | Telp: ${pengguna['no_telepon']}'),
                    onTap: () => _lihatDetail(pengguna),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editPengguna(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapusPengguna(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPengguna,
        child: const Icon(Icons.add),
      ),
    );
  }
}