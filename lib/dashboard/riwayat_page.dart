import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart'; // Pastikan path benar
import '../../services/api_service.dart'; // Import ApiService

class RiwayatPage extends StatefulWidget {
  final String token; // Token wajib diterima dari Dashboard

  const RiwayatPage({super.key, required this.token});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  // State
  List<dynamic> _listRiwayat = [];
  bool _isLoading = true;

  // Controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  // Tanggal biasanya otomatis, tapi kita siapkan controllernya jika ingin edit manual
  final TextEditingController _tanggalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _statusController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  // =======================
  // 1. GET DATA (READ)
  // =======================
  Future<void> _fetchRiwayat() async {
    setState(() => _isLoading = true);
    try {
      // Menggunakan endpoint Transaksi untuk data Riwayat
      final data = await ApiService.getTransaksi(widget.token);
      
      setState(() {
        _listRiwayat = data; // Data dari API
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Gagal memuat data: $e");
      setState(() => _isLoading = false);
    }
  }

  // =======================
  // 2. TAMBAH DATA (CREATE)
  // =======================
  Future<void> _tambahRiwayat() async {
    // Validasi
    if (_namaController.text.isEmpty || _jumlahController.text.isEmpty) {
      _showSnackBar("Nama dan Jumlah wajib diisi");
      return;
    }

    Map<String, dynamic> data = {
      "nama_pelanggan": _namaController.text,
      "total_biaya": int.tryParse(_jumlahController.text) ?? 0,
      "status": _statusController.text.isEmpty ? "Selesai" : _statusController.text,
      // Default tanggal hari ini jika kosong
      "tanggal_transaksi": _tanggalController.text.isEmpty 
          ? DateTime.now().toString().split(' ')[0] 
          : _tanggalController.text,
    };

    try {
      final response = await ApiService.createTransaksi(widget.token, data);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context);
        _clearInput();
        _showSnackBar("Riwayat berhasil ditambahkan");
        _fetchRiwayat();
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
  Future<void> _updateRiwayat(int id) async {
    Map<String, dynamic> data = {
      "nama_pelanggan": _namaController.text,
      "total_biaya": int.tryParse(_jumlahController.text) ?? 0,
      "status": _statusController.text,
      "tanggal_transaksi": _tanggalController.text,
    };

    try {
      final response = await ApiService.updateTransaksi(id, widget.token, data);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context);
        _clearInput();
        _showSnackBar("Riwayat berhasil diperbarui");
        _fetchRiwayat();
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
  Future<void> _hapusRiwayat(int id) async {
    try {
      final response = await ApiService.deleteTransaksi(id, widget.token);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context); // Tutup dialog
        _showSnackBar("Riwayat berhasil dihapus");
        _fetchRiwayat();
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

  void _clearInput() {
    _namaController.clear();
    _jumlahController.clear();
    _statusController.clear();
    _tanggalController.clear();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // Dialog Form
  void _showFormDialog({Map<String, dynamic>? data}) {
    final isEdit = data != null;

    if (isEdit) {
      _namaController.text = data['nama_pelanggan'] ?? data['nama'] ?? '';
      _jumlahController.text = (data['total_biaya'] ?? data['jumlah'] ?? 0).toString();
      _statusController.text = data['status'] ?? '';
      _tanggalController.text = data['tanggal_transaksi'] ?? '';
    } else {
      _clearInput();
      _tanggalController.text = DateTime.now().toString().split(' ')[0];
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Riwayat' : 'Tambah Riwayat'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Pengguna / Pelanggan'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tanggalController,
                decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'Status (Selesai/Diproses)'),
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
              if (isEdit) {
                int id = data['id_transaksi'] ?? data['id'];
                _updateRiwayat(id);
              } else {
                _tambahRiwayat();
              }
            },
            child: Text(isEdit ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  // Dialog Hapus
  void _showDeleteDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: Text('Yakin ingin menghapus riwayat atas nama "${data['nama_pelanggan'] ?? data['nama']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              int id = data['id_transaksi'] ?? data['id'];
              _hapusRiwayat(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Detail Transaksi
  void _lihatDetail(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detail Transaksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${data['nama_pelanggan'] ?? data['nama']}'),
            const SizedBox(height: 8),
            Text('Tanggal: ${data['tanggal_transaksi'] ?? '-'}'),
            const SizedBox(height: 8),
            Text('Jumlah: Rp ${data['total_biaya'] ?? 0}'),
            const SizedBox(height: 8),
            Text('Status: ${data['status'] ?? '-'}'),
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
      appBar: const CustomAppBar(title: 'Riwayat Transaksi'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listRiwayat.isEmpty
              ? const Center(child: Text('Belum ada riwayat transaksi'))
              : ListView.builder(
                  itemCount: _listRiwayat.length,
                  itemBuilder: (context, index) {
                    final riwayat = _listRiwayat[index];
                    
                    // Mapping Data
                    String nama = riwayat['nama_pelanggan'] ?? riwayat['nama'] ?? 'Tanpa Nama';
                    String tanggal = riwayat['tanggal_transaksi'] ?? riwayat['created_at'] ?? '-';
                    String jumlah = (riwayat['total_biaya'] ?? 0).toString();
                    String status = riwayat['status'] ?? 'Selesai';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: status == 'Selesai' ? Colors.green : Colors.orange,
                          child: const Icon(Icons.history, color: Colors.white),
                        ),
                        title: Text('$nama - Rp $jumlah'),
                        subtitle: Text('$tanggal • $status'),
                        onTap: () => _lihatDetail(riwayat),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showFormDialog(data: riwayat),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(riwayat),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahRiwayat, // Panggil modal form kosong
        child: const Icon(Icons.add),
      ),
    );
  }
}