import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  // Data dummy pengguna
  List<Map<String, dynamic>> daftarPengguna = [
    {'id': 1, 'nama': 'Alfina Berlian', 'email': 'alfina@gmail.com', 'role': 'Admin'},
    {'id': 2, 'nama': 'Dicky Sanjaya', 'email': 'dicky@gmail.com', 'role': 'User'},
    {'id': 3, 'nama': 'Difvo Erza', 'email': 'difvo@gmail.com', 'role': 'User'},
  ];

  // Controller form
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();

  // Tambah pengguna baru
  void _tambahPengguna() {
    _namaController.clear();
    _emailController.clear();
    _roleController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pengguna'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Role (Admin/User)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_namaController.text.isNotEmpty && _emailController.text.isNotEmpty) {
                setState(() {
                  daftarPengguna.add({
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'nama': _namaController.text,
                    'email': _emailController.text,
                    'role': _roleController.text.isEmpty ? 'User' : _roleController.text,
                  });
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Edit pengguna
  void _editPengguna(int index) {
    final pengguna = daftarPengguna[index];
    _namaController.text = pengguna['nama'];
    _emailController.text = pengguna['email'];
    _roleController.text = pengguna['role'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pengguna'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Role (Admin/User)'),
            ),
          ],
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
                  'id': pengguna['id'],
                  'nama': _namaController.text,
                  'email': _emailController.text,
                  'role': _roleController.text,
                };
              });
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Hapus pengguna
  void _hapusPengguna(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text(
          'Yakin ingin menghapus pengguna "${daftarPengguna[index]['nama']}"?',
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

  // Detail pengguna (opsional)
  void _lihatDetail(Map<String, dynamic> pengguna) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pengguna['nama']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${pengguna['email']}'),
            const SizedBox(height: 5),
            Text('Role: ${pengguna['role']}'),
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
                    title: Text(pengguna['nama']),
                    subtitle: Text('${pengguna['email']} • ${pengguna['role']}'),
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
