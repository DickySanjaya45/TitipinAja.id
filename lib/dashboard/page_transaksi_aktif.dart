import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PageTransaksiAktif extends StatefulWidget {
  final String token;

  const PageTransaksiAktif({super.key, required this.token});

  @override
  State<PageTransaksiAktif> createState() => _PageTransaksiAktifState();
}

class _PageTransaksiAktifState extends State<PageTransaksiAktif> {
  List<dynamic> _dataList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getAktivitas(widget.token);
      
      if (mounted) {
        setState(() {
          _dataList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Opsional: Beri tahu user jika error, tapi jangan blocking
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e"), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Transaksi Aktif"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _dataList.isEmpty 
              ? const _EmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _dataList.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _TransactionCard(data: _dataList[index]);
                    },
                  ),
                ),
    );
  }
}

// ===============================================================
// 🧩 WIDGET COMPONENTS (Dipisah agar kode lebih ringan & rapi)
// ===============================================================

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TransactionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    // Safe Data Mapping
    // Prioritas: Data Motor -> Plat Nomor -> Default Text
    final String motor = data['motor']?['merk'] ?? data['plat_nomor'] ?? 'Kendaraan';
    final String slot = data['slot'] ?? '-';
    final String jamMasuk = data['waktu_masuk'] ?? data['created_at'] ?? '-';
    final String status = data['status'] ?? 'Aktif';
    final String biaya = (data['biaya'] ?? 0).toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_parking, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(slot, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        jamMasuk, 
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status & Biaya
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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