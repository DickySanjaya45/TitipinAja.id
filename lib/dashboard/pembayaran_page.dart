import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart'; // Pastikan path benar
import '../../services/api_service.dart'; // Import ApiService

class PembayaranPage extends StatefulWidget {
  final String token; // Token wajib

  const PembayaranPage({super.key, required this.token});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  // State
  List<dynamic> _daftarPembayaran = [];
  bool _isLoading = true;

  // Controller
  final _namaController = TextEditingController(); // Bisa jadi Keterangan / Nama Pelanggan
  final _jumlahController = TextEditingController(); // Total Biaya
  final _tanggalController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    _fetchPembayaran();
  }

  // =======================
  // 1. GET DATA (READ)
  // =======================
  Future<void> _fetchPembayaran() async {
    setState(() => _isLoading = true);
    try {
      // Menggunakan endpoint Transaksi
      final data = await ApiService.getTransaksi(widget.token);
      setState(() {
        _daftarPembayaran = data;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Gagal mengambil data: $e");
      setState(() => _isLoading = false);
    }
  }

  // =======================
  // 2. TAMBAH DATA (CREATE)
  // =======================
  Future<void> _tambahPembayaran() async {
    // Siapkan data sesuai kolom database Anda
    // Pastikan key JSON ('nama', 'total_biaya', dll) sesuai dengan Controller Laravel Anda
    Map<String, dynamic> data = {
      'nama_pelanggan': _namaController.text, // Sesuaikan dengan DB
      'total_biaya': int.tryParse(_jumlahController.text) ?? 0,
      'tanggal_transaksi': _tanggalController.text, // Format YYYY-MM-DD
    };

    try {
      // PENTING: Pastikan Anda menambahkan method createTransaksi di ApiService
      final response = await ApiService.createTransaksi(widget.token, data);

      if (response['success'] == true) {
        _showSnackBar("Pembayaran berhasil disimpan");
        if (!mounted) return;
        Navigator.pop(context);
        _clearControllers();
        _fetchPembayaran();
      } else {
        _showSnackBar("Gagal: ${response['message']}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // =======================
  // 3. EDIT DATA (UPDATE)
  // =======================
  Future<void> _updatePembayaran(int id) async {
    Map<String, dynamic> data = {
      'nama_pelanggan': _namaController.text,
      'total_biaya': int.tryParse(_jumlahController.text) ?? 0,
      'tanggal_transaksi': _tanggalController.text,
    };

    try {
      // PENTING: Pastikan Anda menambahkan method updateTransaksi di ApiService
      final response = await ApiService.updateTransaksi(id, widget.token, data);

      if (response['success'] == true) {
        _showSnackBar("Data berhasil diperbarui");
        if (!mounted) return;
        Navigator.pop(context);
        _clearControllers();
        _fetchPembayaran();
      } else {
        _showSnackBar("Gagal: ${response['message']}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // =======================
  // 4. HAPUS DATA (DELETE)
  // =======================
  Future<void> _hapusPembayaran(int id) async {
    try {
      // PENTING: Pastikan Anda menambahkan method deleteTransaksi di ApiService
      final response = await ApiService.deleteTransaksi(id, widget.token);

      if (response['success'] == true) {
        _showSnackBar("Data berhasil dihapus");
        if (!mounted) return;
        Navigator.pop(context);
        _fetchPembayaran();
      } else {
        _showSnackBar("Gagal menghapus: ${response['message']}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // =======================
  // HELPER & UI
  // =======================

  void _clearControllers() {
    _namaController.clear();
    _jumlahController.clear();
    _tanggalController.clear();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Dialog Form
  void _showFormDialog({Map<String, dynamic>? item}) {
    bool isEdit = item != null;

    if (isEdit) {
      // Sesuaikan key dengan respon API
      _namaController.text = item['nama_pelanggan'] ?? item['nama'] ?? '';
      _jumlahController.text = (item['total_biaya'] ?? item['jumlah'] ?? 0).toString();
      _tanggalController.text = item['tanggal_transaksi'] ?? item['tanggal'] ?? '';
    } else {
      _clearControllers();
      // Auto set tanggal hari ini
      _tanggalController.text = DateTime.now().toString().split(' ')[0];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Pembayaran' : 'Tambah Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Pelanggan / Keterangan'),
            ),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
            ),
            TextField(
              controller: _tanggalController,
              decoration: const InputDecoration(
                labelText: 'Tanggal (YYYY-MM-DD)',
                hintText: '2025-10-30'
              ),
              onTap: () async {
                 // Opsional: Tambahkan DatePicker di sini
              },
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
              if (isEdit) {
                int id = item['id_transaksi'] ?? item['id'];
                _updatePembayaran(id);
              } else {
                _tambahPembayaran();
              }
            },
            child: Text(isEdit ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  // Dialog Hapus
  void _showDeleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pembayaran'),
        content: Text('Hapus data senilai Rp ${item['total_biaya'] ?? item['jumlah']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              int id = item['id_transaksi'] ?? item['id'];
              _hapusPembayaran(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pembayaran'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _daftarPembayaran.isEmpty
              ? const Center(child: Text('Belum ada data pembayaran'))
              : ListView.builder(
                  itemCount: _daftarPembayaran.length,
                  itemBuilder: (context, index) {
                    final data = _daftarPembayaran[index];
                    
                    // Mapping data agar aman
                    String nama = data['nama_pelanggan'] ?? data['nama'] ?? '-';
                    String jumlah = (data['total_biaya'] ?? data['jumlah'] ?? 0).toString();
                    String tanggal = data['tanggal_transaksi'] ?? data['tanggal'] ?? '-';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.attach_money, color: Colors.white),
                        ),
                        title: Text('Rp $jumlah'),
                        subtitle: Text('$nama • $tanggal'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showFormDialog(item: data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(data),
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