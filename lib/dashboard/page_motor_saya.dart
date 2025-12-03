import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/motor_model.dart'; // Pastikan import model yang baru dibuat

class PageMotorSaya extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData; // Butuh data user untuk filter ID

  const PageMotorSaya({
    super.key, 
    required this.token, 
    required this.userData
  });

  @override
  State<PageMotorSaya> createState() => _PageMotorSayaState();
}

class _PageMotorSayaState extends State<PageMotorSaya> {
  List<MotorModel> _listMotor = [];
  bool _isLoading = true;

  // Controller
  final TextEditingController merkController = TextEditingController();
  final TextEditingController platController = TextEditingController();
  final TextEditingController warnaController = TextEditingController();
  final TextEditingController tahunController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMotorSaya();
  }

  @override
  void dispose() {
    merkController.dispose();
    platController.dispose();
    warnaController.dispose();
    tahunController.dispose();
    super.dispose();
  }

  // --- LOGIKA API ---

  // 1. Ambil Data
  Future<void> _fetchMotorSaya() async {
    setState(() => _isLoading = true);
    try {
      final rawData = await ApiService.getMotor(widget.token);
      
      // Ambil ID User yang sedang login
      int myUserId = widget.userData['id_pengguna'] ?? widget.userData['id'];

      setState(() {
        // Filter: Hanya ambil motor yang id_pengguna-nya sama dengan user login
        _listMotor = rawData
            .map((json) => MotorModel.fromJson(json))
            .where((motor) => motor.idPengguna == myUserId)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Gagal memuat data: $e");
      setState(() => _isLoading = false);
    }
  }

  // 2. Tambah Data
  Future<void> _tambahMotor() async {
    int myUserId = widget.userData['id_pengguna'] ?? widget.userData['id'];

    Map<String, dynamic> data = {
      "id_pengguna": myUserId, // Otomatis pakai ID sendiri
      "merk": merkController.text,
      "plat_nomor": platController.text,
      "warna": warnaController.text,
      "tahun": int.tryParse(tahunController.text) ?? DateTime.now().year,
    };

    try {
      final response = await ApiService.createMotor(widget.token, data);
      if (!mounted) return;
      if (response['success'] == true) {
        Navigator.pop(context);
        _showSnackBar("Motor berhasil ditambahkan");
        _fetchMotorSaya();
      } else {
        _showSnackBar("Gagal: ${response['message']}");
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error: $e");
    }
  }

  // 3. Update Data
  Future<void> _updateMotor(int idMotor) async {
    int myUserId = widget.userData['id_pengguna'] ?? widget.userData['id'];

    Map<String, dynamic> data = {
      "id_pengguna": myUserId,
      "merk": merkController.text,
      "plat_nomor": platController.text,
      "warna": warnaController.text,
      "tahun": int.tryParse(tahunController.text) ?? 2020,
    };

    try {
      final response = await ApiService.updateMotor(idMotor, widget.token, data);
      if (!mounted) return;
      if (response['success'] == true) {
        Navigator.pop(context);
        _showSnackBar("Motor berhasil diperbarui");
        _fetchMotorSaya();
      } else {
        _showSnackBar("Gagal: ${response['message']}");
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error: $e");
    }
  }

  // 4. Hapus Data
  Future<void> _hapusMotor(int idMotor) async {
    try {
      final response = await ApiService.deleteMotor(idMotor, widget.token);
      if (!mounted) return;
      if (response['success'] == true) {
        Navigator.pop(context); // Tutup dialog
        _showSnackBar("Motor berhasil dihapus");
        _fetchMotorSaya();
      } else {
        _showSnackBar("Gagal menghapus: ${response['message']}");
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error menghapus motor: $e");
    }
  }

  // --- HELPER & UI ---

  void _resetForm() {
    merkController.clear();
    platController.clear();
    warnaController.clear();
    tahunController.clear();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // Form Modal (Tambah/Edit)
  void _showFormDialog({MotorModel? motor}) {
    bool isEdit = motor != null;

    if (isEdit) {
      merkController.text = motor.merk;
      platController.text = motor.platNomor;
      warnaController.text = motor.warna;
      tahunController.text = motor.tahun.toString();
    } else {
      _resetForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 25,
          left: 22,
          right: 22,
          bottom: MediaQuery.of(context).viewInsets.bottom + 22,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEdit ? "Edit Motor" : "Tambah Motor",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            _buildTextField(merkController, "Merk Motor (Cth: Honda Vario)"),
            const SizedBox(height: 12),
            _buildTextField(platController, "Plat Nomor (Cth: B 1234 XYZ)"),
            const SizedBox(height: 12),
            _buildTextField(warnaController, "Warna (Cth: Hitam)"),
            const SizedBox(height: 12),
            _buildTextField(tahunController, "Tahun (Cth: 2023)", isNumber: true),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () {
                if (merkController.text.isEmpty || platController.text.isEmpty) {
                  _showSnackBar("Merk dan Plat Nomor wajib diisi!");
                  return;
                }
                if (isEdit) {
                  _updateMotor(motor.idMotor);
                } else {
                  _tambahMotor();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B2B9C),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isEdit ? "Simpan Perubahan" : "Tambah Motor",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Konfirmasi Hapus
  void _showDeleteDialog(MotorModel motor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Motor"),
        content: Text("Yakin ingin menghapus ${motor.merk}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _hapusMotor(motor.idMotor),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motor Saya"),
        backgroundColor: const Color(0xFF5B2B9C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listMotor.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada motor terdaftar.",
                    style: TextStyle(fontSize: 17, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _listMotor.length,
                  itemBuilder: (context, index) {
                    final motor = _listMotor[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFF5B2B9C).withAlpha((0.1 * 255).round()),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.motorcycle,
                            color: Color(0xFF5B2B9C),
                            size: 30,
                          ),
                        ),
                        title: Text(
                          motor.merk,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Plat: ${motor.platNomor}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              Text(
                                "Warna: ${motor.warna} • Tahun: ${motor.tahun}",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'edit') _showFormDialog(motor: motor);
                            if (value == 'delete') _showDeleteDialog(motor);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text("Edit")),
                            const PopupMenuItem(value: 'delete', child: Text("Hapus", style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: const Color(0xFF5B2B9C),
        child: const Icon(Icons.add),
      ),
    );
  }
}