import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PageOperasional extends StatefulWidget {
  final String token;
  const PageOperasional({super.key, required this.token});

  @override
  State<PageOperasional> createState() => _PageOperasionalState();
}

class _PageOperasionalState extends State<PageOperasional> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // --- CONTROLLERS MASUK ---
  final _namaUserCtrl = TextEditingController();
  final _alamatUserCtrl = TextEditingController(); // TAMBAHAN: Input Alamat
  final _telpUserCtrl = TextEditingController();
  final _platCtrl = TextEditingController();
  final _merkCtrl = TextEditingController();
  final _warnaCtrl = TextEditingController();

  // --- CONTROLLERS KELUAR ---
  final _kodeTransaksiCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _namaUserCtrl.dispose();
    _alamatUserCtrl.dispose(); // Jangan lupa dispose
    _telpUserCtrl.dispose();
    _platCtrl.dispose();
    _merkCtrl.dispose();
    _warnaCtrl.dispose();
    _kodeTransaksiCtrl.dispose();
    super.dispose();
  }

  // ===============================================================
  // 🟢 LOGIC: PROSES MASUK (Check-In)
  // ===============================================================
  Future<void> _handleCheckIn() async {
    // Validasi Input
    if (_namaUserCtrl.text.isEmpty || 
        _alamatUserCtrl.text.isEmpty || 
        _telpUserCtrl.text.isEmpty || 
        _platCtrl.text.isEmpty || 
        _merkCtrl.text.isEmpty) {
      _showMsg("Mohon lengkapi semua data (Nama, Alamat, Telp, Plat, Merk)!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil SATU Endpoint CheckIn saja (Backend yang akan handle logic User/Motor/Slot)
      final response = await ApiService.checkIn(widget.token, {
        "nama": _namaUserCtrl.text,           // Sesuai DB baru
        "alamat": _alamatUserCtrl.text,       // Sesuai DB baru
        "no_telepon": _telpUserCtrl.text,     // Sesuai DB baru
        "plat_nomor": _platCtrl.text,
        "merk_motor": _merkCtrl.text,
        "warna": _warnaCtrl.text.isEmpty ? "-" : _warnaCtrl.text,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response['success'] == true) {
        final data = response['data'];
        // Tampilkan Struk dari respon backend
        // Backend mengembalikan: tiket, slot, dll
        _showStrukDialog(
          data['tiket'] ?? data['kode_tiket'] ?? '-', 
          data['slot'] ?? data['lokasi_parkir'] ?? 'Auto',
          _platCtrl.text
        );
        _clearInputMasuk();
      } else {
        _showMsg(response['message'] ?? "Gagal Check-In", Colors.red);
      }

    } catch (e) {
      setState(() => _isLoading = false);
      _showMsg("Gagal Check-In: $e", Colors.red);
    }
  }

  void _showStrukDialog(String kode, String slot, String plat) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Center(child: Text("TIKET PARKIR", style: TextStyle(fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 100),
            const SizedBox(height: 10),
            Text(kode, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const Text("Kode Transaksi", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(thickness: 2),
            _rowDetail("Lokasi Parkir", slot),
            _rowDetail("Plat Nomor", plat),
            const SizedBox(height: 10),
            const Text("Simpan struk ini untuk pengambilan!", style: TextStyle(fontSize: 12, color: Colors.red), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B2B9C)),
            child: const Text("Cetak / Selesai", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // ===============================================================
  // 🔴 LOGIC: PROSES KELUAR (Check-Out)
  // ===============================================================
  Future<void> _handleCheckOutSearch() async {
    if (_kodeTransaksiCtrl.text.isEmpty) {
      _showMsg("Masukkan Kode Transaksi", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil API Cek Tiket
      final res = await ApiService.cekTiket(widget.token, _kodeTransaksiCtrl.text.trim());
      
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        final data = res['data'];
        _showPaymentDialog(
          data, 
          int.tryParse(data['total_tagihan'].toString()) ?? 0, 
          data['durasi_jam'].toString()
        );
      } else {
        _showMsg(res['message'] ?? "Tiket tidak ditemukan", Colors.red);
      }

    } catch (e) {
      setState(() => _isLoading = false);
      _showMsg("Error: $e", Colors.red);
    }
  }

  void _showPaymentDialog(Map<String, dynamic> data, int total, String durasi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pembayaran Parkir"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _rowDetail("Kode", data['kode_tiket']),
            _rowDetail("Plat", data['plat_nomor']),
            _rowDetail("Durasi", "$durasi Jam"),
            const Divider(),
            Text("Rp $total", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            const Text("Pilih Metode Pembayaran:"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _paymentButton(ctx, "CASH", Icons.money, Colors.green, () => _processPayment(data['kode_tiket'], "Cash")),
                _paymentButton(ctx, "QRIS", Icons.qr_code, Colors.blue, () => _processPayment(data['kode_tiket'], "QRIS")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _paymentButton(BuildContext ctx, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
      child: Column(
        children: [
          CircleAvatar(radius: 25, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Future<void> _processPayment(String kodeTiket, String metode) async {
    setState(() => _isLoading = true);
    try {
      // Panggil API Checkout
      final res = await ApiService.checkOut(widget.token, kodeTiket, metode);

      setState(() {
        _isLoading = false;
        _kodeTransaksiCtrl.clear();
      });

      if (res['success'] == true) {
        _showMsg("Pembayaran Berhasil! Slot telah dikosongkan.", Colors.green);
      } else {
        _showMsg(res['message'] ?? "Gagal Checkout", Colors.red);
      }

    } catch (e) {
      setState(() => _isLoading = false);
      _showMsg("Gagal memproses pembayaran: $e", Colors.red);
    }
  }

  // ===============================================================
  // 🖌️ UI UTAMA
  // ===============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Operasional Parkir"),
        backgroundColor: const Color(0xFF5B2B9C),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.login), text: "KEDATANGAN"),
            Tab(icon: Icon(Icons.logout), text: "PENGAMBILAN"),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildFormMasuk(),
              _buildFormKeluar(),
            ],
          ),
    );
  }

  Widget _buildFormMasuk() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BAGIAN USER
          const Text("Data Pengguna", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _input(_namaUserCtrl, "Nama Pengguna (Wajib)", Icons.person),
          const SizedBox(height: 10),
          _input(_alamatUserCtrl, "Alamat (Wajib)", Icons.home), // Field Baru
          const SizedBox(height: 10),
          _input(_telpUserCtrl, "No. Telepon (Wajib)", Icons.phone, isNumber: true),
          
          const SizedBox(height: 24),
          
          // BAGIAN MOTOR
          const Text("Data Kendaraan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _input(_platCtrl, "Plat Nomor (Wajib)", Icons.confirmation_number_outlined),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _input(_merkCtrl, "Merk (Honda/Yamaha)", Icons.motorcycle)),
              const SizedBox(width: 10),
              Expanded(child: _input(_warnaCtrl, "Warna (Opsional)", Icons.color_lens)),
            ],
          ),
          
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _handleCheckIn,
            icon: const Icon(Icons.save),
            label: const Text("PROSES MASUK & CETAK TIKET"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B2B9C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormKeluar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("Scan QR / Input Kode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _kodeTransaksiCtrl,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 2, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "KODE TIKET",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleCheckOutSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("CEK BIAYA & KELUAR"),
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _input(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
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
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _clearInputMasuk() {
    _namaUserCtrl.clear();
    _alamatUserCtrl.clear();
    _telpUserCtrl.clear();
    _platCtrl.clear();
    _merkCtrl.clear();
    _warnaCtrl.clear();
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}