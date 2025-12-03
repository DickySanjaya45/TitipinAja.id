import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // Import ApiService

class PageMember extends StatefulWidget {
  final String token; // Token wajib
  final Map<String, dynamic> userData; // Data user login

  const PageMember({
    super.key, 
    required this.token, 
    required this.userData
  });

  @override
  State<PageMember> createState() => _PageMemberState();
}

class _PageMemberState extends State<PageMember> {
  // State Data
  List<dynamic> _listMember = [];
  bool _isLoading = true;

  // Controllers
  // Sesuaikan field ini dengan struktur tabel 'member' di database Anda
  // Misal: id_member, id_pengguna, tanggal_daftar, masa_aktif, diskon, dll.
  final TextEditingController _idMemberController = TextEditingController(); 
  final TextEditingController _diskonController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMember();
  }

  @override
  void dispose() {
    _idMemberController.dispose();
    _diskonController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  // =======================
  // 1. GET DATA (READ)
  // =======================
  Future<void> _fetchMember() async {
    setState(() => _isLoading = true);
    try {
      // PENTING: Pastikan Anda sudah membuat method getMember di ApiService
      // Jika belum ada, tambahkan dulu di api_service.dart
      final data = await ApiService.getMember(widget.token); 
      
      setState(() {
        _listMember = data;
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
  Future<void> _tambahMember() async {
    // Siapkan data sesuai kolom database
    Map<String, dynamic> data = {
      // id_member biasanya auto-increment atau generate di backend
      // Tapi kalau manual input:
      "id_member_manual": _idMemberController.text, 
      "diskon": _diskonController.text,
      "tanggal_daftar": _tanggalController.text,
      // Hubungkan dengan user yang login (opsional, tergantung struktur DB)
      "id_pengguna": widget.userData['id_pengguna'] ?? widget.userData['id'], 
    };

    try {
      // PENTING: Tambahkan createMember di ApiService
      final response = await ApiService.createMember(widget.token, data);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context);
        _clearInput();
        _showSnackBar("Member berhasil ditambahkan");
        _fetchMember(); 
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
  Future<void> _updateMember(int id) async {
    Map<String, dynamic> data = {
      "diskon": _diskonController.text,
      "tanggal_daftar": _tanggalController.text,
    };

    try {
      // PENTING: Tambahkan updateMember di ApiService
      final response = await ApiService.updateMember(id, widget.token, data);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context);
        _clearInput();
        _showSnackBar("Data member berhasil diperbarui");
        _fetchMember();
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
  Future<void> _hapusMember(int id) async {
    try {
      // PENTING: Tambahkan deleteMember di ApiService
      final response = await ApiService.deleteMember(id, widget.token);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context); 
        _showSnackBar("Member berhasil dihapus");
        _fetchMember();
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
    _idMemberController.clear();
    _diskonController.clear();
    _tanggalController.clear();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // Form Dialog
  void _showMemberForm({Map<String, dynamic>? data}) {
    final isEdit = data != null;

    if (isEdit) {
      _idMemberController.text = (data['id_member'] ?? data['id']).toString();
      _diskonController.text = data['diskon'] ?? '';
      _tanggalController.text = data['tanggal_daftar'] ?? '';
    } else {
      _clearInput();
      // Auto set tanggal hari ini
      _tanggalController.text = DateTime.now().toString().split(' ')[0];
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? "Edit Member" : "Daftar Member",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Jika ID Member auto-generate, field ini bisa dihilangkan atau read-only
            TextField(
              controller: _idMemberController,
              decoration: const InputDecoration(labelText: "ID Member (Opsional)"),
              enabled: !isEdit, // ID biasanya tidak boleh diedit
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tanggalController,
              decoration: const InputDecoration(labelText: "Tanggal Daftar"),
              readOnly: true, // Biar user tidak salah format, gunakan DatePicker jika perlu
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _diskonController,
              decoration: const InputDecoration(labelText: "Diskon / Keterangan"),
            ),
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
                // Ambil ID primary key dari database (misal: id_member atau id)
                int id = data['id_member'] ?? data['id']; 
                _updateMember(id);
              } else {
                _tambahMember();
              }
            },
            child: Text(isEdit ? "Update" : "Simpan"),
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
        title: const Text("Hapus Member"),
        content: const Text("Yakin ingin menghapus status member ini?"),
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
              int id = data['id_member'] ?? data['id'];
              _hapusMember(id);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Member"),
        backgroundColor: const Color(0xFF5B2B9C),
        foregroundColor: Colors.white,
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listMember.isEmpty
              ? const Center(
                  child: Text(
                    "Anda belum terdaftar sebagai member.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _listMember.length,
                  itemBuilder: (context, index) {
                    final member = _listMember[index];
                    
                    // Ambil Data dengan Null Safety
                    String idMem = (member['id_member'] ?? member['id']).toString();
                    String tgl = member['tanggal_daftar'] ?? '-';
                    String diskon = member['diskon'] ?? '0%';

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF5B2B9C).withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.card_membership,
                            color: Color(0xFF5B2B9C),
                            size: 32,
                          ),
                        ),
                        title: Text(
                          "ID: $idMem",
                          style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text("Terdaftar: $tgl\nBenefit: $diskon"),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _showMemberForm(data: member),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _showDeleteDialog(member),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5B2B9C),
        icon: const Icon(Icons.add),
        label: const Text("Daftar Member"),
        onPressed: () => _showMemberForm(),
      ),
    );
  }
}