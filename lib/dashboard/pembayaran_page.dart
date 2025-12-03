import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart'; 
import '../../services/api_service.dart';

class PembayaranPage extends StatefulWidget {
  final String token;

  const PembayaranPage({super.key, required this.token});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  // State Variables
  List<dynamic> _listPembayaran = [];
  bool _isLoading = true;

  // Controllers
  final _namaCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _tanggalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // OPTIMISASI: Hapus controller dari memori saat halaman ditutup
  @override
  void dispose() {
    _namaCtrl.dispose();
    _jumlahCtrl.dispose();
    _tanggalCtrl.dispose();
    super.dispose();
  }

  // =======================
  // 1. GET DATA
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

  // =======================
  // 2. CREATE & UPDATE LOGIC
  // =======================
  Future<void> _submitForm({int? id}) async {
    // Validasi Input
    if (_namaCtrl.text.isEmpty || _jumlahCtrl.text.isEmpty) {
      _showMsg("Nama dan Jumlah wajib diisi!");
      return;
    }

    Navigator.pop(context); // Tutup dialog segera agar UI responsif
    setState(() => _isLoading = true);

    // Siapkan Data
    Map<String, dynamic> data = {
      'nama_pelanggan': _namaCtrl.text,
      'total_biaya': int.tryParse(_jumlahCtrl.text) ?? 0,
      // Jika tanggal kosong, pakai tanggal hari ini
      'tanggal_transaksi': _tanggalCtrl.text.isNotEmpty 
          ? _tanggalCtrl.text 
          : DateTime.now().toString().split(' ')[0], 
    };

    try {
      final response = id == null
          ? await ApiService.createTransaksi(widget.token, data)
          : await ApiService.updateTransaksi(id, widget.token, data);

      if (response['success'] == true) {
        _showMsg(id == null ? "Pembayaran berhasil disimpan" : "Data diperbarui");
        _clearCtrl();
        _fetchData(); // Refresh list
      } else {
        _showMsg("Gagal: ${response['message']}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMsg("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // =======================
  // 3. DELETE LOGIC
  // =======================
  Future<void> _deleteItem(int id) async {
    Navigator.pop(context); // Tutup dialog
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.deleteTransaksi(id, widget.token);

      if (response['success'] == true) {
        _showMsg("Data dihapus");
        _fetchData();
      } else {
        _showMsg("Gagal menghapus: ${response['message']}");
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
      _tanggalCtrl.text = item['tanggal_transaksi'] ?? item['tanggal'] ?? '';
    } else {
      _clearCtrl();
      _tanggalCtrl.text = DateTime.now().toString().split(' ')[0];
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Pembayaran' : 'Tambah Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInput("Nama Pelanggan", _namaCtrl),
            const SizedBox(height: 12),
            _buildInput("Jumlah (Rp)", _jumlahCtrl, isNumber: true),
            const SizedBox(height: 12),
            _buildInput("Tanggal (YYYY-MM-DD)", _tanggalCtrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B2B9C)),
            onPressed: () {
              int? id = item != null ? (item['id_transaksi'] ?? item['id']) : null;
              _submitForm(id: id);
            },
            child: Text(isEdit ? 'Update' : 'Simpan', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openDeleteConfirm(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Hapus pembayaran atas nama "${item['nama_pelanggan'] ?? '-'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              int id = item['id_transaksi'] ?? item['id'];
              _deleteItem(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
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
      ),
    );
  }

  // =======================
  // MAIN BUILD
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pembayaran'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listPembayaran.isEmpty
              ? const Center(child: Text('Belum ada data pembayaran'))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _listPembayaran.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data = _listPembayaran[index];
                      
                      // Safe Data Mapping
                      String nama = data['nama_pelanggan'] ?? '-';
                      String jumlah = (data['total_biaya'] ?? 0).toString();
                      String tanggal = data['tanggal_transaksi'] ?? '-';

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.attach_money, color: Colors.white),
                          ),
                          title: Text('Rp $jumlah', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$nama • $tanggal'),
                          trailing: PopupMenuButton(
                            onSelected: (value) => value == 'edit' 
                                ? _openForm(item: data) 
                                : _openDeleteConfirm(data),
                            itemBuilder: (context) => [
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
        backgroundColor: const Color(0xFF5B2B9C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}