import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../widgets/custom_appbar.dart';

class ParkirPage extends StatefulWidget {
  final String token;

  const ParkirPage({super.key, required this.token});

  @override
  State<ParkirPage> createState() => _ParkirPageState();
}

class _ParkirPageState extends State<ParkirPage> {
  // State
  List<dynamic> _listSlot = [];
  bool _isLoading = true;

  // Controllers
  final _nomorCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  String _selectedStatus = 'Tersedia';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // OPTIMISASI: Hapus controller dari memori
  @override
  void dispose() {
    _nomorCtrl.dispose();
    _lokasiCtrl.dispose();
    super.dispose();
  }

  // =======================
  // 1. DATA OPERATIONS (API)
  // =======================
  
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getSlotParkir(widget.token);
      setState(() {
        _listSlot = data;
        _isLoading = false;
      });
    } catch (e) {
      _showMsg("Gagal memuat data");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm({int? id}) async {
    if (_nomorCtrl.text.isEmpty || _lokasiCtrl.text.isEmpty) {
      _showMsg("Semua field wajib diisi");
      return;
    }

    Navigator.pop(context); // Tutup dialog
    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      "nomor_slot": _nomorCtrl.text,
      "lokasi": _lokasiCtrl.text,
      "status": _selectedStatus,
    };

    try {
      final response = id == null
          ? await ApiService.createSlotParkir(widget.token, data)
          : await ApiService.updateSlotParkir(id, widget.token, data);

      if (response['success'] == true) {
        _showMsg(id == null ? "Slot ditambahkan" : "Data diperbarui");
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
      final response = await ApiService.deleteSlotParkir(id, widget.token);
      if (response['success'] == true) {
        _showMsg("Slot dihapus");
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
    _nomorCtrl.clear();
    _lokasiCtrl.clear();
    _selectedStatus = 'Tersedia';
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
      _nomorCtrl.text = item['nomor_slot'] ?? '';
      _lokasiCtrl.text = item['lokasi'] ?? '';
      _selectedStatus = item['status'] ?? 'Tersedia';
    } else {
      _clearCtrl();
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // StatefulBuilder agar Dropdown update realtime
        builder: (context, setStateModal) => AlertDialog(
          title: Text(isEdit ? "Edit Slot" : "Tambah Slot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput("Nomor Slot (Cth: A-1)", _nomorCtrl),
              const SizedBox(height: 12),
              _buildInput("Lokasi (Cth: Lantai 1)", _lokasiCtrl),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'Tersedia', child: Text('Tersedia')),
                  DropdownMenuItem(value: 'Terisi', child: Text('Terisi')),
                ],
                onChanged: (val) => setStateModal(() => _selectedStatus = val!),
              ),
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
                int? id = isEdit ? (item['id_parkir_slot'] ?? item['id']) : null;
                _submitForm(id: id);
              },
              child: Text(isEdit ? "Update" : "Simpan", style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _openDeleteConfirm(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Slot?"),
        content: Text("Yakin ingin menghapus slot ${item['nomor_slot']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _deleteData(item['id_parkir_slot'] ?? item['id']),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
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
      appBar: const CustomAppBar(title: 'Slot Parkir'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listSlot.isEmpty
              ? const Center(child: Text("Belum ada data slot parkir"))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _listSlot.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final slot = _listSlot[index];
                      // Safe Mapping
                      String no = slot['nomor_slot'] ?? '-';
                      String loc = slot['lokasi'] ?? '-';
                      String status = slot['status'] ?? 'Tersedia';
                      bool isFull = status == 'Terisi';

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(
                            isFull ? Icons.directions_car_filled : Icons.local_parking,
                            color: isFull ? Colors.red : Colors.green,
                            size: 32,
                          ),
                          title: Text("Slot $no", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("$loc • $status"),
                          trailing: PopupMenuButton(
                            onSelected: (val) => val == 'edit' 
                                ? _openForm(item: slot) 
                                : _openDeleteConfirm(slot),
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