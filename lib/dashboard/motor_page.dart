import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart'; // Pastikan path ini benar
import '../../services/api_service.dart'; // Import ApiService

class MotorPage extends StatefulWidget {
  final String token; // Token wajib diterima dari Dashboard

  const MotorPage({super.key, required this.token});

  @override
  State<MotorPage> createState() => _MotorPageState();
}

class _MotorPageState extends State<MotorPage> {
  // Variabel State
  List<dynamic> _daftarMotor = [];
  bool _isLoading = true;

  // Controller
  final TextEditingController platController = TextEditingController();
  final TextEditingController merkController = TextEditingController();
  final TextEditingController warnaController = TextEditingController();
  final TextEditingController tahunController = TextEditingController();
  final TextEditingController penggunaIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMotor();
  }

  // =======================
  //  1. GET DATA (READ)
  // =======================
  Future<void> _fetchMotor() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await ApiService.getMotor(widget.token);
      setState(() {
        _daftarMotor = data;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Gagal mengambil data: $e");
      setState(() => _isLoading = false);
    }
  }

  // =======================
  //  2. TAMBAH MOTOR
  // =======================
  Future<void> _tambahMotor() async {
    // Validasi input sederhana
    if (penggunaIdController.text.isEmpty || platController.text.isEmpty) {
      _showSnackBar("ID Pengguna dan Plat Nomor wajib diisi");
      return;
    }

    Map<String, dynamic> data = {
      "id_pengguna": int.tryParse(penggunaIdController.text) ?? 0,
      "merk": merkController.text,
      "plat_nomor": platController.text,
      "warna": warnaController.text,
      "tahun": int.tryParse(tahunController.text) ?? DateTime.now().year,
    };

    try {
      final response = await ApiService.createMotor(widget.token, data);

      if (response['success'] == true) {
        _showSnackBar("Motor berhasil ditambahkan");
        if (!mounted) return;
        Navigator.pop(context);
        _clearControllers();
        _fetchMotor(); // Refresh data
      } else {
        _showSnackBar("Gagal: ${response['message']}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // =======================
  //  3. UPDATE MOTOR
  // =======================
  Future<void> _updateMotor(int id) async {
    Map<String, dynamic> data = {
      "id_pengguna": int.tryParse(penggunaIdController.text) ?? 0,
      "merk": merkController.text,
      "plat_nomor": platController.text,
      "warna": warnaController.text,
      "tahun": int.tryParse(tahunController.text) ?? 2020,
    };

    try {
      final response = await ApiService.updateMotor(id, widget.token, data);

      if (response['success'] == true) {
        _showSnackBar("Data motor berhasil diperbarui");
        if (!mounted) return;
        Navigator.pop(context);
        _clearControllers();
        _fetchMotor();
      } else {
        _showSnackBar("Gagal: ${response['message']}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // =======================
  //  4. HAPUS MOTOR
  // =======================
  Future<void> _hapusMotor(int id) async {
    try {
      final response = await ApiService.deleteMotor(id, widget.token);

      if (response['success'] == true) {
        _showSnackBar("Motor berhasil dihapus");
        if (!mounted) return;
        Navigator.pop(context); // Tutup dialog konfirmasi
        _fetchMotor();
      } else {
        _showSnackBar("Gagal menghapus: ${response['message']}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // =======================
  //  HELPER & UI
  // =======================
  
  void _clearControllers() {
    platController.clear();
    merkController.clear();
    warnaController.clear();
    tahunController.clear();
    penggunaIdController.clear();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Dialog Form (Tambah/Edit)
  void _showFormDialog({Map<String, dynamic>? motor}) {
    bool isEdit = motor != null;

    if (isEdit) {
      platController.text = motor["plat_nomor"] ?? '';
      merkController.text = motor["merk"] ?? '';
      warnaController.text = motor["warna"] ?? '';
      tahunController.text = motor["tahun"].toString();
      penggunaIdController.text = motor["id_pengguna"].toString();
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Motor" : "Tambah Motor"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(penggunaIdController, "ID Pengguna (Wajib)", isNumber: true),
              _buildTextField(platController, "Plat Nomor"),
              _buildTextField(merkController, "Merk Motor"),
              _buildTextField(warnaController, "Warna"),
              _buildTextField(tahunController, "Tahun", isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (isEdit) {
                int id = motor['id_motor'] ?? motor['id'];
                _updateMotor(id);
              } else {
                _tambahMotor();
              }
            },
            child: Text(isEdit ? "Update" : "Simpan"),
          ),
        ],
      ),
    );
  }

  // Dialog Konfirmasi Hapus
  void _showDeleteDialog(Map<String, dynamic> motor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Motor"),
        content: Text("Yakin ingin menghapus motor ${motor['merk']} (${motor['plat_nomor']})?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
               int id = motor['id_motor'] ?? motor['id'];
              _hapusMotor(id);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Data Motor"),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _daftarMotor.isEmpty
              ? const Center(child: Text("Belum ada data motor"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _daftarMotor.length,
                  itemBuilder: (context, i) {
                    final m = _daftarMotor[i];
                    
                    // Ambil nama pemilik dengan aman (Null Safety)
                    // Backend mungkin mengirim object 'pengguna', atau null jika relasi gagal
                    String namaPemilik = "ID: ${m['id_pengguna']}";
                    if (m['pengguna'] != null && m['pengguna']['nama_lengkap'] != null) {
                      namaPemilik = m['pengguna']['nama_lengkap'];
                    }

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade50,
                          child: const Icon(Icons.motorcycle, color: Colors.deepPurple),
                        ),
                        title: Text(m["merk"] ?? "Tanpa Merk", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Plat: ${m["plat_nomor"]} • ${m["warna"]} • ${m["tahun"]}"),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: Text("Pemilik: $namaPemilik", style: TextStyle(fontSize: 12, color: Colors.blue.shade800)),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'edit') _showFormDialog(motor: m);
                            if (value == 'delete') _showDeleteDialog(m);
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}