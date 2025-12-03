import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../../services/api_service.dart';

class PenggunaPage extends StatefulWidget {
  final String token;

  const PenggunaPage({super.key, required this.token});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  // State
  List<dynamic> _listPengguna = [];
  bool _isLoading = true;

  // Controllers
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // OPTIMISASI: Hapus controller dari memori
  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _telpCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // =======================
  // 1. DATA OPERATIONS (API)
  // =======================
  
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getPengguna(widget.token);
      setState(() {
        _listPengguna = data;
        _isLoading = false;
      });
    } catch (e) {
      _showMsg("Gagal memuat data");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm({int? id}) async {
    if (_namaCtrl.text.isEmpty || _emailCtrl.text.isEmpty) {
      _showMsg("Nama dan Email wajib diisi");
      return;
    }

    Navigator.pop(context); // Tutup dialog
    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      'nama_lengkap': _namaCtrl.text,
      'alamat': _alamatCtrl.text,
      'no_telepon': _telpCtrl.text,
      'email': _emailCtrl.text,
    };

    // Password hanya dikirim jika diisi (untuk update) atau wajib (untuk create)
    if (_passCtrl.text.isNotEmpty) {
      data['password'] = _passCtrl.text;
    }

    try {
      final response = id == null
          ? await ApiService.createPengguna(widget.token, data)
          : await ApiService.updatePengguna(id, widget.token, data);

      if (response['success'] == true) {
        _showMsg(id == null ? "Pengguna ditambahkan" : "Data diperbarui");
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
      final response = await ApiService.deletePengguna(id, widget.token);
      if (response['success'] == true) {
        _showMsg("Pengguna dihapus");
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
    _alamatCtrl.clear();
    _telpCtrl.clear();
    _emailCtrl.clear();
    _passCtrl.clear();
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
      _namaCtrl.text = item['nama_lengkap'] ?? '';
      _alamatCtrl.text = item['alamat'] ?? '';
      _telpCtrl.text = item['no_telepon'] ?? '';
      _emailCtrl.text = item['email'] ?? '';
      _passCtrl.clear();
    } else {
      _clearCtrl();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Pengguna" : "Tambah Pengguna"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput("Nama Lengkap", _namaCtrl),
              const SizedBox(height: 12),
              _buildInput("Email", _emailCtrl, isEmail: true),
              const SizedBox(height: 12),
              _buildInput("No. Telepon", _telpCtrl, isNumber: true),
              const SizedBox(height: 12),
              _buildInput("Alamat", _alamatCtrl, maxLines: 2),
              const SizedBox(height: 12),
              _buildInput(
                isEdit ? "Password (Kosongkan jika tetap)" : "Password", 
                _passCtrl, 
                isPass: true
              ),
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
              int? id = isEdit ? (item['id_pengguna'] ?? item['id']) : null;
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
        title: const Text("Hapus Pengguna?"),
        content: Text("Yakin ingin menghapus ${item['nama_lengkap']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _deleteData(item['id_pengguna'] ?? item['id']),
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
        title: Text(item['nama_lengkap'] ?? 'Detail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID: ${item['id_pengguna'] ?? item['id']}"),
            const SizedBox(height: 8),
            Text("Email: ${item['email']}"),
            const SizedBox(height: 8),
            Text("Telp: ${item['no_telepon']}"),
            const SizedBox(height: 8),
            Text("Alamat: ${item['alamat']}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup")),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, {bool isNumber = false, bool isEmail = false, bool isPass = false, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      obscureText: isPass,
      maxLines: maxLines,
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
      appBar: const CustomAppBar(title: 'Data Pengguna'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listPengguna.isEmpty
              ? const Center(child: Text("Belum ada data pengguna"))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _listPengguna.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _listPengguna[index];
                      // Safe Mapping
                      String name = item['nama_lengkap'] ?? '-';
                      String email = item['email'] ?? '-';
                      String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(child: Text(initial)),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(email),
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
        backgroundColor: const Color(0xFF5B2B9C),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _openForm(),
      ),
    );
  }
}