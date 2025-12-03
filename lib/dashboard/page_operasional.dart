import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PageOperasional extends StatefulWidget {
  final String token;
  const PageOperasional({super.key, required this.token});

  @override
  State<PageOperasional> createState() => _PageOperasionalState();
}

class _PageOperasionalState extends State<PageOperasional> {
  List<dynamic> _parkirAktif = [];
  bool _isLoading = true;

  // Tarif per jam
  final int _tarifPerJam = 2000;

  // Controllers untuk Check-in Manual
  final _platCtrl = TextEditingController();
  final _merkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Mengambil data transaksi yang statusnya masih 'Aktif' / 'Masuk'
      final rawData = await ApiService.getAktivitas(widget.token);
      if (mounted) {
        setState(() {
          // Filter hanya yang statusnya belum selesai (Asumsi 'status' dari API)
          _parkirAktif = rawData
              .where((item) => item['status'] != 'Selesai')
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC CHECK-IN (MASUK) ---
  Future<void> _prosesMasuk() async {
    if (_platCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Plat nomor wajib diisi")));
      return;
    }

    Navigator.pop(context);
    setState(() => _isLoading = true);

    // Kirim data ke API (Create Transaksi)
    try {
      await ApiService.createTransaksi(widget.token, {
        "plat_nomor": _platCtrl.text,
        "merk": _merkCtrl.text, // Opsional jika API butuh
        "status": "Aktif",
        "waktu_masuk": DateTime.now().toIso8601String(), // Catat waktu sekarang
        "total_biaya": 0, // Belum ada biaya
      });
      _platCtrl.clear();
      _merkCtrl.clear();
      _fetchData(); // Refresh list
      _showMsg("Kendaraan Berhasil Masuk", Colors.green);
    } catch (e) {
      _showMsg("Gagal Check-in: $e", Colors.red);
      _fetchData();
    }
  }

  // --- LOGIC CHECK-OUT (KELUAR & BAYAR) ---
  void _konfirmasiKeluar(Map<String, dynamic> item) {
    // 1. Hitung Durasi
    DateTime waktuMasuk =
        DateTime.tryParse(item['waktu_masuk'] ?? '') ?? DateTime.now();
    DateTime waktuKeluar = DateTime.now();

    Duration durasi = waktuKeluar.difference(waktuMasuk);
    int jamParkir = durasi.inHours;
    if (durasi.inMinutes % 60 > 0)
      jamParkir++; // Pembulatan ke atas (1 jam 5 menit = 2 jam)
    if (jamParkir == 0) jamParkir = 1; // Minimal 1 jam

    // 2. Hitung Biaya
    int totalBiaya = jamParkir * _tarifPerJam;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Pembayaran"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowDetail(
              "Kendaraan",
              item['motor']?['merk'] ?? item['plat_nomor'] ?? '-',
            ),
            const Divider(),
            _rowDetail("Waktu Masuk", _formatTime(waktuMasuk)),
            _rowDetail("Waktu Keluar", _formatTime(waktuKeluar)),
            _rowDetail("Durasi", "$jamParkir Jam"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.green.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL BAYAR:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Rp $totalBiaya",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "*Tarif Rp 2.000 / jam",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B2B9C),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _prosesBayar(item['id_transaksi'] ?? item['id'], totalBiaya);
            },
            child: const Text(
              "Bayar & Selesai",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _prosesBayar(int id, int biaya) async {
    setState(() => _isLoading = true);
    try {
      // Update Transaksi di API
      await ApiService.updateTransaksi(id, widget.token, {
        "status": "Selesai",
        "total_biaya": biaya,
        "waktu_keluar": DateTime.now().toIso8601String(),
      });
      _showMsg("Transaksi Selesai. Pembayaran Berhasil.", Colors.green);
      _fetchData();
    } catch (e) {
      _showMsg("Gagal memproses pembayaran: $e", Colors.red);
      setState(() => _isLoading = false);
    }
  }

  // --- UI HELPERS ---
  void _showFormMasuk() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Kendaraan Masuk"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _platCtrl,
              decoration: const InputDecoration(
                labelText: "Plat Nomor (Cth: AE 1234 XX)",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _merkCtrl,
              decoration: const InputDecoration(labelText: "Merk (Opsional)"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: _prosesMasuk,
            child: const Text("Check In"),
          ),
        ],
      ),
    );
  }

  Widget _rowDetail(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _parkirAktif.isEmpty
          ? const Center(child: Text("Tidak ada kendaraan parkir saat ini"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _parkirAktif.length,
              itemBuilder: (ctx, i) {
                final item = _parkirAktif[i];
                final String plat =
                    item['plat_nomor'] ??
                    item['motor']?['plat_nomor'] ??
                    'Tanpa Plat';
                final String masuk = item['waktu_masuk'] != null
                    ? _formatTime(DateTime.parse(item['waktu_masuk']))
                    : '-';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: const Icon(
                        Icons.local_parking,
                        color: Colors.green,
                      ),
                    ),
                    title: Text(
                      plat,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text("Masuk jam: $masuk"),
                    trailing: ElevatedButton(
                      onPressed: () => _konfirmasiKeluar(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                      ),
                      child: const Text("KELUAR"),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFormMasuk,
        backgroundColor: const Color(0xFF5B2B9C),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Kendaraan Masuk",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
