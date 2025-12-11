import 'package:flutter/material.dart';
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

  final _platCtrl = TextEditingController();
  final _merkCtrl = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _fetchMotor();
  }

  @override
  void dispose() {
    _platCtrl.dispose();
    _merkCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMotor() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMotor(widget.token);
      setState(() {
        _listMotor = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // --- UI CRUD SEDERHANA ---
  // (Anda bisa kembangkan CRUD lengkap seperti PenggunaPage di atas)
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _listMotor.length,
              itemBuilder: (context, i) {
                final m = _listMotor[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.two_wheeler),
                    title: Text(m['plat_nomor'] ?? '-'),
                    subtitle: Text("${m['merk']} • ${m['warna']}"),
                    // Tampilkan pemilik jika ada relasi
                    trailing: Text(m['pengguna']?['nama'] ?? ''),
                  ),
                );
              },
            ),
    );
  }
}