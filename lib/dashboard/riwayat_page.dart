import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  // Data dummy riwayat transaksi
  List<Map<String, dynamic>> daftarRiwayat = [
    {
      'id': 1,
      'nama': 'Alfina Berlian',
      'tanggal': '2025-10-30',
      'jumlah': 25000,
      'status': 'Selesai'
    },
    {
      'id': 2,
      'nama': 'Dicky Sanjaya',
      'tanggal': '2025-10-31',
      'jumlah': 40000,
      'status': 'Diproses'
    },
  ];

  // Controller form
  final _namaController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _statusController = TextEditingController();

  // Tambah riwayat baru
  void _tambahRiwayat() {
    _namaController.clear();
    _tanggalController.clear();
    _jumlahController.clear();
    _statusController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Riwayat Transaksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Pengguna'),
            ),
            TextField(
              controller: _tanggalController,
              decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
            ),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(labelText: 'Status (Selesai/Diproses/Dibatalkan)'),
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
                daftarRiwayat.add({
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'nama': _namaController.text,
                  'tanggal': _tanggalController.text,
                  'jumlah': int.tryParse(_jumlahController.text) ?? 0,
                  'status': _statusController.text,
                });
              });
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Edit riwayat
  void _editRiwayat(int index) {
    final riwayat = daftarRiwayat[index];
    _namaController.text = riwayat['nama'];
    _tanggalController.text = riwayat['tanggal'];
    _jumlahController.text = riwayat['jumlah'].toString();
    _statusController.text = riwayat['status'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Riwayat Transaksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Pengguna'),
            ),
            TextField(
              controller: _tanggalController,
              decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
            ),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(labelText: 'Status (Selesai/Diproses/Dibatalkan)'),
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
                daftarRiwayat[index] = {
                  'id': riwayat['id'],
                  'nama': _namaController.text,
                  'tanggal': _tanggalController.text,
                  'jumlah': int.tryParse(_jumlahController.text) ?? 0,
                  'status': _statusController.text,
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

  // Hapus riwayat
  void _hapusRiwayat(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: Text(
            'Yakin ingin menghapus riwayat transaksi milik "${daftarRiwayat[index]['nama']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                daftarRiwayat.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Detail transaksi
  void _lihatDetail(Map<String, dynamic> riwayat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Transaksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${riwayat['nama']}'),
            Text('Tanggal: ${riwayat['tanggal']}'),
            Text('Jumlah: Rp ${riwayat['jumlah']}'),
            Text('Status: ${riwayat['status']}'),
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
      appBar: const CustomAppBar(title: 'Riwayat Transaksi'),
      body: daftarRiwayat.isEmpty
          ? const Center(child: Text('Belum ada riwayat transaksi'))
          : ListView.builder(
              itemCount: daftarRiwayat.length,
              itemBuilder: (context, index) {
                final riwayat = daftarRiwayat[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('${riwayat['nama']} - Rp ${riwayat['jumlah']}'),
                    subtitle: Text('${riwayat['tanggal']} • ${riwayat['status']}'),
                    onTap: () => _lihatDetail(riwayat),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editRiwayat(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapusRiwayat(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahRiwayat,
        child: const Icon(Icons.add),
      ),
    );
  }
}
