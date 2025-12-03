import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../../services/api_service.dart';

class MotorPage extends StatefulWidget {
  final String token;

  const MotorPage({super.key, required this.token});

  @override
  State<MotorPage> createState() => _MotorPageState();
}

class _MotorPageState extends State<MotorPage> {
  List<dynamic> _listMotor = [];
  bool _isLoading = true;

  // Controllers
  final _platCtrl = TextEditingController();
  final _merkCtrl = TextEditingController();
  final _warnaCtrl = TextEditingController();
  final _tahunCtrl = TextEditingController();
  final _userIdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMotor();
  }

  // PENTING: Hapus controller agar memori hemat
  @override
  void dispose() {
    _platCtrl.dispose();
    _merkCtrl.dispose();
    _warnaCtrl.dispose();
    _tahunCtrl.dispose();
    _userIdCtrl.dispose();
    super.dispose();
  }

  // --- 1. GET DATA ---
  Future<void> _fetchMotor() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMotor(widget.token);
      setState(() {
        _listMotor = data;
        _isLoading = false;
      });
    } catch (e) {
      _showMsg("Gagal memuat data");
      setState(() => _isLoading = false);
    }
  }

  // --- 2. CREATE / UPDATE ---
  Future<void> _submitForm({int? id}) async {
    if (_userIdCtrl.text.isEmpty || _platCtrl.text.isEmpty) {
      _showMsg("ID Pengguna & Plat Nomor wajib diisi");
      return;
    }

    Navigator.pop(context); // Tutup dialog dulu biar smooth
    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      "id_pengguna": int.tryParse(_userIdCtrl.text) ?? 0,
      "merk": _merkCtrl.text,
      "plat_nomor": _platCtrl.text,
      "warna": _warnaCtrl.text,
      "tahun": int.tryParse(_tahunCtrl.text) ?? DateTime.now().year,
    };

    try {
      final response = id == null
          ? await ApiService.createMotor(widget.token, data)
          : await ApiService.updateMotor(id, widget.token, data);

      if (response['success'] == true) {
        _showMsg(id == null ? "Berhasil ditambah" : "Berhasil diupdate");
        _clearCtrl();
        _fetchMotor();
      } else {
        _showMsg(response['message'] ?? "Gagal");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMsg("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- 3. DELETE ---
  Future<void> _deleteMotor(int id) async {
    Navigator.pop(context); // Tutup dialog
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.deleteMotor(id, widget.token);
      if (response['success'] == true) {
        _showMsg("Motor dihapus");
        _fetchMotor();
      } else {
        _showMsg("Gagal menghapus");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMsg("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- HELPER ---
  void _clearCtrl() {
    _platCtrl.clear(); _merkCtrl.clear(); _warnaCtrl.clear();
    _tahunCtrl.clear(); _userIdCtrl.clear();
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), behavior: SnackBarBehavior.floating,
    ));
  }

  // --- UI DIALOGS ---
  void _openForm({Map<String, dynamic>? data}) {
    bool isEdit = data != null;
    if (isEdit) {
      _userIdCtrl.text = data['id_pengguna'].toString();
      _platCtrl.text = data['plat_nomor'] ?? '';
      _merkCtrl.text = data['merk'] ?? '';
      _warnaCtrl.text = data['warna'] ?? '';
      _tahunCtrl.text = data['tahun'].toString();
    } else {
      _clearCtrl();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Motor" : "Tambah Motor"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _inputField(_userIdCtrl, "ID Pengguna (Wajib)", isNumber: true),
              _inputField(_platCtrl, "Plat Nomor"),
              _inputField(_merkCtrl, "Merk"),
              _inputField(_warnaCtrl, "Warna"),
              _inputField(_tahunCtrl, "Tahun", isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => _submitForm(id: data?['id_motor'] ?? data?['id']),
            child: Text(isEdit ? "Update" : "Simpan"),
          ),
        ],
      ),
    );
  }

  void _openDeleteConfirm(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus?"),
        content: Text("Hapus motor ${data['merk']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _deleteMotor(data['id_motor'] ?? data['id']),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController c, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
      ),
    );
  }

  // --- MAIN UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Data Motor"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listMotor.isEmpty
              ? const Center(child: Text("Belum ada data motor"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _listMotor.length,
                  itemBuilder: (context, i) {
                    final m = _listMotor[i];
                    // Logic Simple untuk ambil nama pemilik
                    String pemilik = m['pengguna']?['nama_lengkap'] ?? "ID: ${m['id_pengguna']}";

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade50,
                          child: const Icon(Icons.motorcycle, color: Colors.deepPurple),
                        ),
                        title: Text(m['merk'] ?? "Tanpa Merk", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "${m['plat_nomor']} • ${m['warna']} • ${m['tahun']}\nPemilik: $pemilik",
                          style: TextStyle(height: 1.5, color: Colors.grey[700]),
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (v) => v == 'edit' ? _openForm(data: m) : _openDeleteConfirm(m),
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text("Edit")),
                            const PopupMenuItem(value: 'del', child: Text("Hapus", style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}