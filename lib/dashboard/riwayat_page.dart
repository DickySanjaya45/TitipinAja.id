import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../../services/api_service.dart';

class RiwayatPage extends StatefulWidget {
  final String token;

  const RiwayatPage({super.key, required this.token});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  // State
  List<dynamic> _listRiwayat = [];
  bool _isLoading = true;

  // Controllers
  final _namaCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();
  final _tanggalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // OPTIMISASI: Hapus controller dari memori
  @override
  void dispose() {
    _namaCtrl.dispose();
    _jumlahCtrl.dispose();
    _statusCtrl.dispose();
    _tanggalCtrl.dispose();
    super.dispose();
  }

  // =======================
  // 1. DATA OPERATIONS (API)
  // =======================
  
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Riwayat = Data Transaksi
      final data = await ApiService.getTransaksi(widget.token);
      setState(() {
        _listRiwayat = data;
        _isLoading = false;
      });
    } catch (e) {
      _showMsg("Gagal memuat data");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm({int? id}) async {
    // Validasi
    if (_namaCtrl.text.isEmpty || _jumlahCtrl.text.isEmpty) {
      _showMsg("Nama dan Jumlah wajib diisi");
      return;
    }

    Navigator.pop(context); // Tutup dialog
    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      "nama_pelanggan": _namaCtrl.text,
      "total_biaya": int.tryParse(_jumlahCtrl.text) ?? 0,
      "status": _statusCtrl.text.isEmpty ? "Selesai" : _statusCtrl.text,
      "tanggal_transaksi": _tanggalCtrl.text.isEmpty 
          ? DateTime.now().toString().split(' ')[0] 
          : _tanggalCtrl.text,
    };

    try {
      final response = id == null
          ? await ApiService.createTransaksi(widget.token, data)
          : await ApiService.updateTransaksi(id, widget.token, data);

      if (response['success'] == true) {
        _showMsg(id == null ? "Riwayat ditambahkan" : "Data diperbarui");
        _clearCtrl();
        _fetchData();
      } else {
        _showMsg("Gagal: ${response['message']}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMsg("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteData(int id) async {
    Navigator.pop(context); // Tutup dialog
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.deleteTransaksi(id, widget.token);
      if (response['success'] == true) {
        _showMsg("Data dihapus");
        _fetchData();
      } else {
        _showMsg("Gagal menghapus");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMsg("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // =======================
  // HELPER METHODS
  // =======================
  void _clearCtrl() {
    _namaCtrl.clear();
    _jumlahCtrl.clear();
    _statusCtrl.clear();
    _tanggalCtrl.clear();
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // =======================
  // UI DIALOGS
  // =======================
  void _openForm({Map<String, dynamic>? item}) {
    bool isEdit = item != null;

    if (isEdit) {
      _namaCtrl.text = item['nama_pelanggan'] ?? item['nama'] ?? '';
      _jumlahCtrl.text = (item['total_biaya'] ?? item['jumlah'] ?? 0).toString();
      _statusCtrl.text = item['status'] ?? '';
      _tanggalCtrl.text = item['tanggal_transaksi'] ?? '';
    } else {
      _clearCtrl();
      _tanggalCtrl.text = DateTime.now().toString().split(' ')[0];
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Riwayat" : "Tambah Riwayat"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput("Nama Pengguna / Pelanggan", _namaCtrl),
              const SizedBox(height: 12),
              _buildInput("Jumlah (Rp)", _jumlahCtrl, isNumber: true),
              const SizedBox(height: 12),
              _buildInput("Tanggal (YYYY-MM-DD)", _tanggalCtrl),
              const SizedBox(height: 12),
              _buildInput("Status (Selesai/Diproses)", _statusCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B2B9C)),
            onPressed: () {
              int? id = isEdit ? (item['id_transaksi'] ?? item['id']) : null;
              _submitForm(id: id);
            },
            child: Text(isEdit ? "Update" : "Simpan", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openDeleteConfirm(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Riwayat?"),
        content: Text("Yakin ingin menghapus data atas nama ${item['nama_pelanggan'] ?? '-'}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _deleteData(item['id_transaksi'] ?? item['id']),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDetail(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Detail Transaksi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Nama", item['nama_pelanggan'] ?? '-'),
            _detailRow("Tanggal", item['tanggal_transaksi'] ?? '-'),
            _detailRow("Jumlah", "Rp ${item['total_biaya'] ?? 0}"),
            _detailRow("Status", item['status'] ?? '-'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup")),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // =======================
  // MAIN UI
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Riwayat Transaksi'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listRiwayat.isEmpty
              ? const Center(child: Text("Belum ada riwayat transaksi"))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _listRiwayat.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _listRiwayat[index];
                      // Safe Mapping
                      String nama = item['nama_pelanggan'] ?? item['nama'] ?? 'Tanpa Nama';
                      String tanggal = item['tanggal_transaksi'] ?? '-';
                      String jumlah = (item['total_biaya'] ?? 0).toString();
                      String status = item['status'] ?? 'Selesai';
                      bool isSelesai = status == 'Selesai';

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelesai ? Colors.green : Colors.orange,
                            child: const Icon(Icons.history, color: Colors.white),
                          ),
                          title: Text("$nama - Rp $jumlah", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("$tanggal • $status"),
                          onTap: () => _showDetail(item),
                          trailing: PopupMenuButton(
                            onSelected: (val) => val == 'edit' 
                                ? _openForm(item: item) 
                                : _openDeleteConfirm(item),
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'edit', child: Text("Edit")),
                              const PopupMenuItem(value: 'del', child: Text("Hapus", style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF5B2B9C), // Sesuaikan warna tema
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}