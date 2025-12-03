import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // Import ApiService

class PageTransaksiAktif extends StatefulWidget {
  final String token; // Token wajib

  const PageTransaksiAktif({super.key, required this.token});

  @override
  State<PageTransaksiAktif> createState() => _PageTransaksiAktifState();
}

class _PageTransaksiAktifState extends State<PageTransaksiAktif> {
  // State Data
  List<dynamic> _transaksiAktif = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAktivitas();
  }

  // =======================
  // GET DATA (READ)
  // =======================
  Future<void> _fetchAktivitas() async {
    setState(() => _isLoading = true);
    try {
      // Menggunakan endpoint /aktivitas (yang kita buat di Route Laravel)
      // Endpoint ini seharusnya mengembalikan transaksi yang statusnya 'Masuk' / belum selesai
      final data = await ApiService.getAktivitas(widget.token);
      
      setState(() {
        _transaksiAktif = data;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error diam-diam atau tampilkan snackbar jika perlu
      setState(() => _isLoading = false);
    }
  }

  // Refresh data saat ditarik ke bawah
  Future<void> _refresh() async {
    await _fetchAktivitas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      
      // AppBar Sederhana
      appBar: AppBar(
        title: const Text("Transaksi Aktif"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAktivitas,
          )
        ],
      ),

      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _transaksiAktif.isEmpty 
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _transaksiAktif.length,
                    itemBuilder: (context, index) {
                      final data = _transaksiAktif[index];
                      
                      // Mapping Data (Sesuaikan dengan respon API Anda)
                      // Contoh: { "motor": "Honda Beat", "waktu_masuk": "10:00", "biaya": 2000, "status": "Masuk" }
                      String motor = data['motor']?['merk'] ?? data['plat_nomor'] ?? 'Motor';
                      String slot = data['slot'] ?? '-'; // Jika ada fitur slot
                      String jamMasuk = data['waktu_masuk'] ?? data['created_at'] ?? '-';
                      String status = data['status'] ?? 'Aktif';
                      String biaya = (data['biaya'] ?? 0).toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha((0.05 * 255).round()),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // Icon Status (Jam Pasir / Timer)
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F7FA),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.timer_outlined, color: Color(0xFF00ACC1)),
                              ),
                              const SizedBox(width: 16),
                              
                              // Info Utama
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      motor,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.local_parking, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text("Slot $slot", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(jamMasuk, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Status Chip & Biaya
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withAlpha((0.1 * 255).round()),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Rp $biaya",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // Tampilan Kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_parking_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Tidak ada kendaraan parkir",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}