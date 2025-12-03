import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PagePembayaran extends StatefulWidget {
  final String token;

  const PagePembayaran({super.key, required this.token});

  @override
  State<PagePembayaran> createState() => _PagePembayaranState();
}

class _PagePembayaranState extends State<PagePembayaran> {
  // State
  List<dynamic> _listPembayaran = [];
  bool _isLoading = true;

  // Controllers
  final _ketCtrl = TextEditingController(); // Keterangan/Motor
  final _biayaCtrl = TextEditingController(); // Jumlah
  final _statusCtrl = TextEditingController(); // Status/Metode

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // OPTIMISASI: Hapus controller agar hemat memori
  @override
  void dispose() {
    _ketCtrl.dispose();
    _biayaCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  // =======================
  // 1. DATA OPERATIONS (API)
  // =======================
  
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getTransaksi(widget.token);
      setState(() {
        _listPembayaran = data;
        _isLoading = false;
      });
    } catch (e) {
      _showMsg("Gagal memuat data");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm({int? id}) async {
    // Validasi
    if (_ketCtrl.text.isEmpty || _biayaCtrl.text.isEmpty) {
      _showMsg("Keterangan dan Jumlah wajib diisi!");
      return;
    }

    Navigator.pop(context); // Tutup dialog
    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      "keterangan": _ketCtrl.text,
      "total_biaya": int.tryParse(_biayaCtrl.text) ?? 0,
      "status": _statusCtrl.text.isEmpty ? "Pending" : _statusCtrl.text,
      "tanggal_transaksi": DateTime.now().toString().split(' ')[0], // Auto Today
    };

    try {
      final response = id == null
          ? await ApiService.createTransaksi(widget.token, data)
          : await ApiService.updateTransaksi(id, widget.token, data);

      if (response['success'] == true) {
        _showMsg(id == null ? "Pembayaran ditambahkan" : "Data diperbarui");
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
    _ketCtrl.clear();
    _biayaCtrl.clear();
    _statusCtrl.clear();
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
      _ketCtrl.text = item['keterangan'] ?? item['motor'] ?? '';
      _biayaCtrl.text = (item['total_biaya'] ?? item['jumlah'] ?? 0).toString();
      _statusCtrl.text = item['status'] ?? '';
    } else {
      _clearCtrl();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Pembayaran" : "Tambah Pembayaran"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInput("Keterangan / Motor", _ketCtrl),
            const SizedBox(height: 12),
            _buildInput("Jumlah (Rp)", _biayaCtrl, isNumber: true),
            const SizedBox(height: 12),
            _buildInput("Metode / Status", _statusCtrl),
          ],
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
        title: const Text("Hapus Data?"),
        content: const Text("Yakin ingin menghapus data ini?"),
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

  Widget _buildInput(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  // =======================
  // MAIN UI
  // =======================
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
              ? const Center(child: Text("Belum ada data pembayaran", style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _listPembayaran.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _listPembayaran[index];
                      // Safe Mapping
                      String ket = item['keterangan'] ?? item['motor'] ?? '-';
                      String jml = (item['total_biaya'] ?? 0).toString();
                      String status = item['status'] ?? '-';
                      String tgl = item['tanggal_transaksi'] ?? '-';

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B2B9C),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.payment, color: Colors.white, size: 28),
                          ),
                          title: Text(ket, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text("Rp $jml • $status\n$tgl", style: const TextStyle(height: 1.4)),
                          isThreeLine: true,
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
        backgroundColor: const Color(0xFF5B2B9C),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _openForm(),
      ),
    );
  }
}