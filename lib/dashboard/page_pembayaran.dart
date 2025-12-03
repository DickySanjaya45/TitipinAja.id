import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // Import ApiService

class PagePembayaran extends StatefulWidget {
  final String token; // Token wajib dari Dashboard

  const PagePembayaran({super.key, required this.token});

  @override
  State<PagePembayaran> createState() => _PagePembayaranState();
}

class _PagePembayaranState extends State<PagePembayaran> {
  // State Data
  List<dynamic> _listPembayaran = [];
  bool _isLoading = true;

  // Controllers
  final TextEditingController motorController = TextEditingController(); // Di database: 'keterangan'
  final TextEditingController jumlahController = TextEditingController(); // Di database: 'total_biaya'
  final TextEditingController metodeController = TextEditingController(); // Di database: 'status'

  @override
  void initState() {
    super.initState();
    _fetchPembayaran();
  }

  @override
  void dispose() {
    motorController.dispose();
    jumlahController.dispose();
    metodeController.dispose();
    super.dispose();
  }

  // =======================
  // 1. GET DATA (READ)
  // =======================
  Future<void> _fetchPembayaran() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getTransaksi(widget.token);
      setState(() {
        _listPembayaran = data;
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
  Future<void> _tambahPembayaran() async {
    // Validasi
    if (motorController.text.isEmpty || jumlahController.text.isEmpty) {
      _showSnackBar("Keterangan dan Jumlah wajib diisi!");
      return;
    }

    // Persiapan Data untuk Backend
    Map<String, dynamic> data = {
      "keterangan": motorController.text, // Input 'Motor' kita simpan ke 'keterangan'
      "total_biaya": int.tryParse(jumlahController.text) ?? 0,
      "status": metodeController.text.isEmpty ? "Pending" : metodeController.text,
      "tanggal_transaksi": DateTime.now().toString().split(' ')[0], // Auto tanggal hari ini
    };

    try {
      final response = await ApiService.createTransaksi(widget.token, data);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context);
        _clearInput();
        _showSnackBar("Pembayaran berhasil ditambahkan");
        _fetchPembayaran(); // Refresh list
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
      "keterangan": motorController.text,
      "total_biaya": int.tryParse(jumlahController.text) ?? 0,
      "status": metodeController.text,
    };

    try {
      final response = await ApiService.updateTransaksi(id, widget.token, data);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context);
        _clearInput();
        _showSnackBar("Data berhasil diperbarui");
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
      final response = await ApiService.deleteTransaksi(id, widget.token);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context); // Tutup dialog
        _showSnackBar("Data berhasil dihapus");
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

  void _clearInput() {
    motorController.clear();
    jumlahController.clear();
    metodeController.clear();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // Form Dialog (Tambah / Edit)
  void _showPembayaranForm({Map<String, dynamic>? data}) {
    final isEdit = data != null;

    if (isEdit) {
      // Mapping data dari Database ke Controller
      motorController.text = data['keterangan'] ?? data['motor'] ?? '';
      jumlahController.text = (data['total_biaya'] ?? data['jumlah'] ?? 0).toString();
      metodeController.text = data['status'] ?? data['metode'] ?? '';
    } else {
      _clearInput();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? "Edit Pembayaran" : "Tambah Pembayaran",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _inputField("Keterangan / Motor", motorController),
            const SizedBox(height: 12),
            _inputField("Jumlah (Rp)", jumlahController, type: TextInputType.number),
            const SizedBox(height: 12),
            _inputField("Metode (Tunai/Transfer)", metodeController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearInput();
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B2B9C),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (isEdit) {
                // Ambil ID Transaksi (Pastikan key sesuai response API, biasanya id_transaksi atau id)
                int id = data['id_transaksi'] ?? data['id'];
                _updatePembayaran(id);
              } else {
                _tambahPembayaran();
              }
            },
            child: Text(isEdit ? "Update" : "Simpan"),
          ),
        ],
      ),
    );
  }

  // Dialog Konfirmasi Hapus
  void _showDeleteDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Pembayaran"),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              int id = data['id_transaksi'] ?? data['id'];
              _hapusPembayaran(id);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Pembayaran"),
        backgroundColor: const Color(0xFF5B2B9C),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listPembayaran.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada data pembayaran",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _listPembayaran.length,
                  itemBuilder: (context, index) {
                    final bayar = _listPembayaran[index];
                    
                    // Ambil Data dengan Null Safety
                    String ket = bayar['keterangan'] ?? bayar['motor'] ?? '-';
                    String jml = (bayar['total_biaya'] ?? 0).toString();
                    String status = bayar['status'] ?? '-';
                    String tgl = bayar['tanggal_transaksi'] ?? bayar['created_at'] ?? '-';

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B2B9C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.payment, color: Colors.white, size: 28),
                        ),
                        title: Text(
                          ket,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            "Rp $jml\nStatus: $status\nTanggal: $tgl",
                            style: const TextStyle(height: 1.4, color: Colors.black87),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showPembayaranForm(data: bayar),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(bayar),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5B2B9C),
        child: const Icon(Icons.add),
        onPressed: () => _showPembayaranForm(),
      ),
    );
  }
}