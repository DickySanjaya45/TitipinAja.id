import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class PembayaranPage extends StatefulWidget {
  const PembayaranPage({super.key});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  // Data dummy pembayaran
  List<Map<String, dynamic>> daftarPembayaran = [
    {'id': 1, 'nama': 'Dicky', 'jumlah': 25000, 'tanggal': '2025-10-30'},
    {'id': 2, 'nama': 'Alfina', 'jumlah': 40000, 'tanggal': '2025-10-31'},
  ];

  // Controller form
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _tanggalController = TextEditingController();

  // Menambahkan data baru
  void _tambahPembayaran() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
            ),
            TextField(
              controller: _tanggalController,
              decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _namaController.clear();
              _jumlahController.clear();
              _tanggalController.clear();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                daftarPembayaran.add({
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'nama': _namaController.text,
                  'jumlah': int.tryParse(_jumlahController.text) ?? 0,
                  'tanggal': _tanggalController.text,
                });
              });
              _namaController.clear();
              _jumlahController.clear();
              _tanggalController.clear();
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Edit data
  void _editPembayaran(int index) {
    final pembayaran = daftarPembayaran[index];
    _namaController.text = pembayaran['nama'];
    _jumlahController.text = pembayaran['jumlah'].toString();
    _tanggalController.text = pembayaran['tanggal'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
            ),
            TextField(
              controller: _tanggalController,
              decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _namaController.clear();
              _jumlahController.clear();
              _tanggalController.clear();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                daftarPembayaran[index] = {
                  'id': pembayaran['id'],
                  'nama': _namaController.text,
                  'jumlah': int.tryParse(_jumlahController.text) ?? 0,
                  'tanggal': _tanggalController.text,
                };
              });
              _namaController.clear();
              _jumlahController.clear();
              _tanggalController.clear();
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Hapus data
  void _hapusPembayaran(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pembayaran'),
        content: Text('Yakin ingin menghapus pembayaran "${daftarPembayaran[index]['nama']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                daftarPembayaran.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pembayaran'),
      body: daftarPembayaran.isEmpty
          ? const Center(child: Text('Belum ada data pembayaran'))
          : ListView.builder(
              itemCount: daftarPembayaran.length,
              itemBuilder: (context, index) {
                final data = daftarPembayaran[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('${data['nama']} - Rp ${data['jumlah']}'),
                    subtitle: Text('Tanggal: ${data['tanggal']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editPembayaran(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapusPembayaran(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPembayaran,
        child: const Icon(Icons.add),
      ),
    );
  }
}
