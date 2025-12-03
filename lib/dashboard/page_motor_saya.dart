import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/motor_model.dart';

class PageMotorSaya extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;

  const PageMotorSaya({super.key, required this.token, required this.userData});

  @override
  State<PageMotorSaya> createState() => _PageMotorSayaState();
}

class _PageMotorSayaState extends State<PageMotorSaya> {
  // State
  List<MotorModel> _listMotor = [];
  bool _isLoading = true;

  // Controllers
  final _merkCtrl = TextEditingController();
  final _platCtrl = TextEditingController();
  final _warnaCtrl = TextEditingController();
  final _tahunCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // 1. CLEANING: Hapus controller dari memori saat widget ditutup
  @override
  void dispose() {
    _merkCtrl.dispose();
    _platCtrl.dispose();
    _warnaCtrl.dispose();
    _tahunCtrl.dispose();
    super.dispose();
  }

  // Helper: Parsing ID aman (menangani String atau Int)
  int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // =======================
  // 2. LOGIC API (Terpisah dari UI)
  // =======================
  
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final rawData = await ApiService.getMotor(widget.token);
      
      // Ambil ID User Login dengan aman
      int myUserId = _parseId(widget.userData['id_pengguna']) != 0 
          ? _parseId(widget.userData['id_pengguna']) 
          : _parseId(widget.userData['id']);

      if (!mounted) return;

      setState(() {
        // Filter data menggunakan Model
        _listMotor = rawData
            .map((json) => MotorModel.fromJson(json))
            .where((motor) => motor.idPengguna == myUserId)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      _showMsg("Gagal memuat data");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm({int? id}) async {
    if (_merkCtrl.text.isEmpty || _platCtrl.text.isEmpty) {
      _showMsg("Merk dan Plat Nomor wajib diisi!");
      return;
    }

    Navigator.pop(context); // Tutup dialog
    setState(() => _isLoading = true);

    int myUserId = _parseId(widget.userData['id_pengguna']) != 0 
          ? _parseId(widget.userData['id_pengguna']) 
          : _parseId(widget.userData['id']);

    Map<String, dynamic> data = {
      "id_pengguna": myUserId,
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
        _showMsg(id == null ? "Motor ditambahkan" : "Data diperbarui");
        _clearCtrl();
        _fetchData();
      } else {
        _showMsg("Gagal: ${response['message']}");
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMsg("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteData(int id) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.deleteMotor(id, widget.token);
      if (response['success'] == true) {
        _showMsg("Motor dihapus");
        _fetchData();
      } else {
        _showMsg("Gagal menghapus");
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMsg("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =======================
  // 3. HELPER UI
  // =======================
  void _clearCtrl() {
    _merkCtrl.clear(); _platCtrl.clear(); _warnaCtrl.clear(); _tahunCtrl.clear();
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _openForm({MotorModel? item}) {
    bool isEdit = item != null;
    if (isEdit) {
      _merkCtrl.text = item.merk;
      _platCtrl.text = item.platNomor;
      _warnaCtrl.text = item.warna;
      _tahunCtrl.text = item.tahun.toString();
    } else {
      _clearCtrl();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 25, left: 22, right: 22,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(isEdit ? "Edit Motor" : "Tambah Motor", textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildInput("Merk Motor", _merkCtrl),
            const SizedBox(height: 12),
            _buildInput("Plat Nomor", _platCtrl),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _buildInput("Warna", _warnaCtrl)), const SizedBox(width: 12), Expanded(child: _buildInput("Tahun", _tahunCtrl, isNumber: true))]),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _submitForm(id: item?.idMotor),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B2B9C), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(isEdit ? "Simpan Perubahan" : "Tambah Motor", style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openDeleteConfirm(MotorModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Motor"),
        content: Text("Yakin ingin menghapus ${item.merk}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _deleteData(item.idMotor),
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
      decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
    );
  }

  // =======================
  // 4. MAIN BUILD
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Motor Saya"), backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0),
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listMotor.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _listMotor.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildMotorCard(_listMotor[index]);
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

  Widget _buildMotorCard(MotorModel motor) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF5B2B9C).withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.motorcycle, color: Color(0xFF5B2B9C)),
        ),
        title: Text(motor.merk, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text("${motor.platNomor} • ${motor.warna}", style: TextStyle(color: Colors.grey[600]))),
        trailing: PopupMenuButton(
          onSelected: (val) => val == 'edit' ? _openForm(item: motor) : _openDeleteConfirm(motor),
          itemBuilder: (ctx) => [const PopupMenuItem(value: 'edit', child: Text("Edit")), const PopupMenuItem(value: 'del', child: Text("Hapus", style: TextStyle(color: Colors.red)))],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.two_wheeler_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Belum ada motor", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}