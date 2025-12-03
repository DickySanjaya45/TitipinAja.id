import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PageMember extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;

  const PageMember({super.key, required this.token, required this.userData});

  @override
  State<PageMember> createState() => _PageMemberState();
}

class _PageMemberState extends State<PageMember> {
  // State
  List<dynamic> _listMember = [];
  bool _isLoading = true;

  // Controllers
  final _idMemberCtrl = TextEditingController();
  final _diskonCtrl = TextEditingController();
  final _tanggalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // OPTIMISASI: Hapus controller agar hemat memori
  @override
  void dispose() {
    _idMemberCtrl.dispose();
    _diskonCtrl.dispose();
    _tanggalCtrl.dispose();
    super.dispose();
  }

  // =======================
  // 1. DATA OPERATIONS (API)
  // =======================
  
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMember(widget.token);
      setState(() {
        _listMember = data;
        _isLoading = false;
      });
    } catch (e) {
      _showMsg("Gagal memuat data");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm({int? id}) async {
    Navigator.pop(context); // Tutup dialog
    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      // Logic: Jika User, ID member otomatis (kosongkan manual). Jika Admin, bisa isi manual.
      "id_member_manual": _idMemberCtrl.text, 
      "diskon": _diskonCtrl.text,
      "tanggal_daftar": _tanggalCtrl.text,
      "id_pengguna": widget.userData['id_pengguna'] ?? widget.userData['id'], 
    };

    try {
      final response = id == null
          ? await ApiService.createMember(widget.token, data)
          : await ApiService.updateMember(id, widget.token, data);

      if (response['success'] == true) {
        _showMsg(id == null ? "Member ditambahkan" : "Data diperbarui");
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
      final response = await ApiService.deleteMember(id, widget.token);
      if (response['success'] == true) {
        _showMsg("Member dihapus");
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
    _idMemberCtrl.clear();
    _diskonCtrl.clear();
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
      _idMemberCtrl.text = (item['id_member'] ?? item['id']).toString();
      _diskonCtrl.text = item['diskon'] ?? '';
      _tanggalCtrl.text = item['tanggal_daftar'] ?? '';
    } else {
      _clearCtrl();
      _tanggalCtrl.text = DateTime.now().toString().split(' ')[0];
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Member" : "Daftar Member"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Field ID hanya aktif jika Tambah Baru (Opsional, tergantung backend)
            _buildInput("ID Member (Opsional)", _idMemberCtrl, enabled: !isEdit),
            const SizedBox(height: 12),
            _buildInput("Tanggal Daftar", _tanggalCtrl, enabled: false), // Read-only date
            const SizedBox(height: 12),
            _buildInput("Diskon / Benefit", _diskonCtrl),
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
              int? id = isEdit ? (item['id_member'] ?? item['id']) : null;
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
        title: const Text("Hapus Member?"),
        content: const Text("Yakin ingin menghapus status member ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _deleteData(item['id_member'] ?? item['id']),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, {bool enabled = true}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: enabled ? null : Colors.grey.shade200,
        filled: !enabled,
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
        title: const Text("Daftar Member"),
        backgroundColor: const Color(0xFF5B2B9C),
        foregroundColor: Colors.white,
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listMember.isEmpty
              ? const Center(child: Text("Anda belum terdaftar sebagai member."))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _listMember.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final member = _listMember[index];
                      // Safe Data Mapping
                      String idMem = (member['id_member'] ?? member['id']).toString();
                      String tgl = member['tanggal_daftar'] ?? '-';
                      String diskon = member['diskon'] ?? '0%';

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF5B2B9C).withOpacity(0.1),
                            child: const Icon(Icons.card_membership, color: Color(0xFF5B2B9C)),
                          ),
                          title: Text("ID: $idMem", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Terdaftar: $tgl\nBenefit: $diskon"),
                          trailing: PopupMenuButton(
                            onSelected: (val) => val == 'edit' 
                                ? _openForm(item: member) 
                                : _openDeleteConfirm(member),
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
      
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5B2B9C),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Daftar Member", style: TextStyle(color: Colors.white)),
        onPressed: () => _openForm(),
      ),
    );
  }
}