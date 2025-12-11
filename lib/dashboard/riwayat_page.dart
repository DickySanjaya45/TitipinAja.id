import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RiwayatPage extends StatefulWidget {
  final String token;
  const RiwayatPage({super.key, required this.token});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<dynamic> _riwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Panggil endpoint list transaksi
      // Note: Di backend, buat endpoint khusus riwayat atau filter di client
      final data = await ApiService.getTransaksi(widget.token);
      
      // Filter hanya yang 'Selesai' di sisi client (atau backend)
      final selesai = data.where((e) => e['status'] == 'Selesai').toList();
      
      setState(() {
        _riwayat = selesai;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _riwayat.isEmpty
              ? const Center(child: Text("Belum ada riwayat transaksi"))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _riwayat.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _riwayat[index];
                    
                    // Mapping Data Aman
                    String plat = item['motor']?['plat_nomor'] ?? '-';
                    String biaya = (item['total_biaya'] ?? 0).toString();
                    String masuk = item['jam_masuk'] ?? '-';
                    String keluar = item['jam_keluar'] ?? '-';
                    String kode = item['kode_tiket'] ?? '-';

                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                        title: Text(plat, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Tiket: $kode\nIn: $masuk\nOut: $keluar"),
                        trailing: Text(
                          "Rp $biaya",
                          style: const TextStyle(
                            color: Colors.green, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 16
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}