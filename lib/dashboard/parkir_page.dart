import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart'; // Pastikan path benar
import '../../services/api_service.dart'; // Import ApiService

class ParkirPage extends StatefulWidget {
  final String token; // Token wajib

  const ParkirPage({super.key, required this.token});

  @override
  State<ParkirPage> createState() => _ParkirPageState();
}

class _ParkirPageState extends State<ParkirPage> {
  List<dynamic> _daftarParkir = [];
  bool _isLoading = true;

  final TextEditingController nomorController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  String statusSelected = 'Tersedia';

  @override
  void initState() {
    super.initState();
    _fetchSlotParkir();
  }

  // =======================
  // 1. GET DATA
  // =======================
  Future<void> _fetchSlotParkir() async {
    setState(() => _isLoading = true);
    try {
      // PENTING: Tambahkan getSlotParkir di ApiService
      final data = await ApiService.getSlotParkir(widget.token);
      setState(() {
        _daftarParkir = data;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Gagal memuat data: $e");
      setState(() => _isLoading = false);
    }
  }

  // =======================
  // 2. TAMBAH DATA
  // =======================
  Future<void> _tambahSlot() async {
    Map<String, dynamic> data = {
      "nomor_slot": nomorController.text,
      "lokasi": lokasiController.text,
      "status": statusSelected,
    };

    try {
      // PENTING: Tambahkan createSlotParkir di ApiService
      final response = await ApiService.createSlotParkir(widget.token, data);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context);
        _clearInput();
        _showSnackBar("Slot parkir berhasil ditambahkan");
        _fetchSlotParkir();
      } else {
        _showSnackBar("Gagal: ${response['message']}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // =======================
  // 3. EDIT DATA
  // =======================
  Future<void> _updateSlot(int id) async {
    Map<String, dynamic> data = {
      "nomor_slot": nomorController.text,
      "lokasi": lokasiController.text,
      "status": statusSelected,
    };

    try {
      // PENTING: Tambahkan updateSlotParkir di ApiService
      final response = await ApiService.updateSlotParkir(id, widget.token, data);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context);
        _clearInput();
        _showSnackBar("Slot parkir berhasil diperbarui");
        _fetchSlotParkir();
      } else {
        _showSnackBar("Gagal: ${response['message']}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // =======================
  // 4. HAPUS DATA
  // =======================
  Future<void> _hapusSlot(int id) async {
    try {
      // PENTING: Tambahkan deleteSlotParkir di ApiService
      final response = await ApiService.deleteSlotParkir(id, widget.token);
      
      if (response['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context); // Tutup dialog
        _showSnackBar("Slot parkir berhasil dihapus");
        _fetchSlotParkir();
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
    nomorController.clear();
    lokasiController.clear();
    statusSelected = 'Tersedia';
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _showForm({Map<String, dynamic>? slot}) {
    bool isEdit = slot != null;

    if (isEdit) {
      nomorController.text = slot['nomor_slot'] ?? '';
      lokasiController.text = slot['lokasi'] ?? '';
      statusSelected = slot['status'] ?? 'Tersedia';
    } else {
      _clearInput();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Slot Parkir' : 'Tambah Slot Parkir'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomorController,
                decoration: const InputDecoration(labelText: 'Nomor Slot'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi Parkir'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: statusSelected,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Tersedia', child: Text('Tersedia')),
                  DropdownMenuItem(value: 'Terisi', child: Text('Terisi')),
                ],
                onChanged: (value) => setState(() => statusSelected = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B2B9C)),
            onPressed: () {
              if (isEdit) {
                // Pastikan key ID sesuai database (misal: id_parkir_slot atau id)
                int id = slot['id_parkir_slot'] ?? slot['id'];
                _updateSlot(id);
              } else {
                _tambahSlot();
              }
            },
            child: Text(isEdit ? 'Update' : 'Simpan', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> slot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Slot Parkir'),
        content: Text('Yakin ingin menghapus slot ${slot['nomor_slot']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              int id = slot['id_parkir_slot'] ?? slot['id'];
              _hapusSlot(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Slot Parkir'),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _daftarParkir.isEmpty
              ? const Center(child: Text('Belum ada data slot parkir'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _daftarParkir.length,
                  itemBuilder: (context, index) {
                    final slot = _daftarParkir[index];
                    String status = slot['status'] ?? 'Tersedia';
                    bool isTerisi = status == 'Terisi';

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(
                          isTerisi ? Icons.directions_car_filled : Icons.local_parking,
                          color: isTerisi ? Colors.red : Colors.green,
                          size: 32,
                        ),
                        title: Text(
                          'Slot ${slot['nomor_slot'] ?? '-'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${slot['lokasi'] ?? '-'} • $status'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showForm(slot: slot),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(slot),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5B2B9C),
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}