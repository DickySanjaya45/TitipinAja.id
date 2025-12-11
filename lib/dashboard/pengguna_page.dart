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
  List<dynamic> _listPengguna = [];
  bool _isLoading = true;

  // Controller Baru (Sesuai Backend)
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _telpCtrl.dispose();
    super.dispose();
  }

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
    if (_namaCtrl.text.isEmpty || _telpCtrl.text.isEmpty) {
      _showMsg("Nama dan No. Telepon wajib diisi");
      return;
    }

    Navigator.pop(context);
    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      'nama': _namaCtrl.text, // Backend sekarang pakai 'nama'
      'alamat': _alamatCtrl.text,
      'no_telepon': _telpCtrl.text,
    };

    try {
      final response = id == null
          ? await ApiService.createPengguna(widget.token, data)
          : await ApiService.updatePengguna(id, widget.token, data);

      if (response['success'] == true || response['data'] != null) {
        _showMsg(id == null ? "Pengguna ditambahkan" : "Data diperbarui");
        _clearCtrl();
        _fetchData();
      } else {
        _showMsg("Gagal: ${response['message'] ?? 'Error'}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMsg("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteData(int id) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.deletePengguna(id, widget.token);
      _showMsg("Pengguna dihapus");
      _fetchData();
    } catch (e) {
      _showMsg("Gagal menghapus");
      setState(() => _isLoading = false);
    }
  }

  void _clearCtrl() {
    _namaCtrl.clear();
    _alamatCtrl.clear();
    _telpCtrl.clear();
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openForm({Map<String, dynamic>? item}) {
    bool isEdit = item != null;
    if (isEdit) {
      _namaCtrl.text = item['nama'] ?? ''; // Pakai 'nama'
      _alamatCtrl.text = item['alamat'] ?? '';
      _telpCtrl.text = item['no_telepon']?.toString() ?? '';
    } else {
      _clearCtrl();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Pengguna" : "Tambah Pengguna"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInput("Nama Lengkap", _namaCtrl),
            const SizedBox(height: 12),
            _buildInput("No. Telepon", _telpCtrl, isNumber: true),
            const SizedBox(height: 12),
            _buildInput("Alamat", _alamatCtrl, maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => _submitForm(id: item?['id_pengguna'] ?? item?['id']),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _listPengguna.length,
              itemBuilder: (context, index) {
                final item = _listPengguna[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text(item['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${item['no_telepon']} \n${item['alamat']}"),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(item: item),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF5B2B9C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}