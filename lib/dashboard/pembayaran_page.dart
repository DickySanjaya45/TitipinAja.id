import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../widgets/custom_appbar.dart';

class PembayaranPage extends StatefulWidget {
  final String token;
  const PembayaranPage({super.key, required this.token});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final _tiketCtrl = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _transaksiData; // Menyimpan hasil scan
  String _metodeBayar = 'Cash';

  // 1. CEK TIKET (Step 1)
  Future<void> _cekTiket() async {
    if (_tiketCtrl.text.isEmpty) {
      _showMsg("Masukkan Kode Tiket!");
      return;
    }

    setState(() { _isLoading = true; _transaksiData = null; });

    try {
      final res = await ApiService.cekTiket(widget.token, _tiketCtrl.text.trim());
      
      if (res['success'] == true) {
        setState(() {
          _transaksiData = res['data'];
          _isLoading = false;
        });
      } else {
        _showMsg(res['message'] ?? "Tiket tidak ditemukan");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMsg("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // 2. PROSES PEMBAYARAN (Step 2)
  Future<void> _prosesBayar() async {
    if (_transaksiData == null) return;

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.checkOut(
        widget.token, 
        _transaksiData!['kode_tiket'], 
        _metodeBayar
      );

      if (res['success'] == true) {
        _showSuccessDialog();
      } else {
        _showMsg(res['message']);
      }
    } catch (e) {
      _showMsg("Gagal memproses pembayaran");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text("Pembayaran Berhasil! Transaksi Selesai.", textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup Dialog
              setState(() {
                _transaksiData = null; // Reset Form
                _tiketCtrl.clear();
              });
            }, 
            child: const Text("OK")
          )
        ],
      ),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Checkout & Pembayaran'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- FORM INPUT KODE TIKET ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("Scan / Input Tiket", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tiketCtrl,
                      decoration: InputDecoration(
                        labelText: "Kode Tiket",
                        hintText: "Contoh: TRX-XY123",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search, color: Color(0xFF5B2B9C)),
                          onPressed: _isLoading ? null : _cekTiket,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _cekTiket,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B2B9C)),
                        child: const Text("CEK BIAYA", style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- HASIL SCAN (DETAIL BIAYA) ---
            if (_isLoading) 
              const CircularProgressIndicator()
            else if (_transaksiData != null)
              Card(
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF5B2B9C), width: 2)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _rowDetail("Kode Tiket", _transaksiData!['kode_tiket']),
                      const Divider(),
                      _rowDetail("Plat Nomor", _transaksiData!['plat_nomor']),
                      _rowDetail("Durasi", "${_transaksiData!['durasi_jam']} Jam"),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("TOTAL BIAYA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            "Rp ${_transaksiData!['total_tagihan']}", 
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Pilihan Metode Bayar
                      const Text("Metode Pembayaran:", style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                              title: const Text("Cash"),
                              value: "Cash",
                              groupValue: _metodeBayar,
                              onChanged: (val) => setState(() => _metodeBayar = val.toString()),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              title: const Text("QRIS"),
                              value: "QRIS",
                              groupValue: _metodeBayar,
                              onChanged: (val) => setState(() => _metodeBayar = val.toString()),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _prosesBayar,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text("BAYAR SEKARANG", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _rowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}