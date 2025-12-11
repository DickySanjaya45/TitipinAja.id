import 'package:flutter/material.dart';
import 'dart:async';
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
    _telpUserCtrl.dispose();
    _platCtrl.dispose();
    _merkCtrl.dispose();
    _warnaCtrl.dispose();
    _kodeTransaksiCtrl.dispose();
    super.dispose();
  }

  // ===============================================================
  // 🟢 LOGIC: PROSES MASUK (Check-In)
  // Alur: Buat User -> Buat Motor -> Cari Slot -> Buat Transaksi
  // ===============================================================
  Future<void> _handleCheckIn() async {
    if (_namaUserCtrl.text.isEmpty || _platCtrl.text.isEmpty) {
      _showMsg("Nama Pengguna dan Plat Nomor wajib diisi!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. BUAT PENGGUNA BARU (Atau logic backend handle existing by phone)
      final userRes = await ApiService.createPengguna(widget.token, {
        "nama_lengkap": _namaUserCtrl.text,
        "no_telepon": _telpUserCtrl.text,
        "email": "-", // Dummy email jika tidak wajib
        "alamat": "-",
      });

      // Validasi ID User (sesuaikan dengan respons backend Anda)
      int userId = userRes['data']?['id'] ?? userRes['data']?['id_pengguna'] ?? 0;
      if (userId == 0) throw Exception("Gagal membuat data pengguna");

      // 2. BUAT DATA MOTOR
      final motorRes = await ApiService.createMotor(widget.token, {
        "id_pengguna": userId,
        "merk": _merkCtrl.text,
        "plat_nomor": _platCtrl.text,
        "warna": _warnaCtrl.text,
        "tahun": DateTime.now().year,
      });
      
      int motorId = motorRes['data']?['id'] ?? motorRes['data']?['id_motor'] ?? 0;
      if (motorId == 0) throw Exception("Gagal membuat data motor");

      // 3. CARI SLOT KOSONG (Ambil dari API Slot)
      final slots = await ApiService.getSlotParkir(widget.token);
      var emptySlot = slots.firstWhere(
        (s) => s['status'] == 'Tersedia', 
        orElse: () => null
      );

      if (emptySlot == null) throw Exception("Parkiran Penuh! Tidak ada slot tersedia.");
      
      int slotId = emptySlot['id'] ?? emptySlot['id_parkir_slot'];
      String namaSlot = emptySlot['nomor_slot'] ?? "A-00";

      // 4. BUAT TRANSAKSI (Start Timer di Server)
      final transRes = await ApiService.createTransaksi(widget.token, {
        "id_motor": motorId,
        "id_parkir_slot": slotId,
        "status": "Aktif",
        "waktu_masuk": DateTime.now().toIso8601String(),
        "total_biaya": 0
      });

      // 5. UPDATE STATUS SLOT JADI 'TERISI'
      await ApiService.updateSlotParkir(slotId, widget.token, {
        "status": "Terisi",
        "nomor_slot": namaSlot, // Kirim ulang data lama agar tidak hilang
        "lokasi": emptySlot['lokasi']
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 6. TAMPILKAN STRUK / KODE QR
      int transId = transRes['data']?['id'] ?? transRes['data']?['id_transaksi'];
      _showStrukDialog(transId.toString(), namaSlot, _platCtrl.text);
      
      _clearInputMasuk();

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
            const Icon(Icons.qr_code_2, size: 100), // Simulasi QR
            const SizedBox(height: 10),
            Text(kode, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const Text("Kode Transaksi", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(thickness: 2),
            _rowDetail("Slot Parkir", slot),
            _rowDetail("Plat Nomor", plat),
            _rowDetail("Waktu", _formatTime(DateTime.now())),
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
  // Alur: Input Kode -> Hitung Biaya -> Bayar -> Update Slot & Transaksi
  // ===============================================================
  Future<void> _handleCheckOutSearch() async {
    if (_kodeTransaksiCtrl.text.isEmpty) {
      _showMsg("Masukkan Kode Transaksi", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. CARI DATA TRANSAKSI
      // Idealnya ada endpoint: GET /transaksi/{id}. 
      // Disini kita filter dari getAll (kurang efisien tapi workable untuk demo)
      final allTrans = await ApiService.getTransaksi(widget.token);
      final transData = allTrans.firstWhere(
        (t) => (t['id'] ?? t['id_transaksi']).toString() == _kodeTransaksiCtrl.text,
        orElse: () => null
      );

      if (transData == null) throw Exception("Kode Transaksi tidak ditemukan.");
      if (transData['status'] == 'Selesai') throw Exception("Transaksi ini sudah selesai dibayar.");

      // 2. HITUNG BIAYA
      DateTime masuk = DateTime.parse(transData['waktu_masuk'] ?? transData['created_at']);
      DateTime keluar = DateTime.now();
      Duration durasi = keluar.difference(masuk);
      
      int jam = durasi.inHours;
      if (durasi.inMinutes % 60 > 0) jam++; // Pembulatan ke atas
      if (jam < 1) jam = 1; // Minimal 1 jam

      int tarifPerJam = 2000;
      int totalBayar = jam * tarifPerJam;

      setState(() => _isLoading = false);

      // 3. TAMPILKAN KONFIRMASI BAYAR
      _showPaymentDialog(transData, totalBayar, jam);

    } catch (e) {
      setState(() => _isLoading = false);
      _showMsg("Error: $e", Colors.red);
    }
  }

  void _showPaymentDialog(Map<String, dynamic> transData, int total, int durasi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pembayaran Parkir"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _rowDetail("Kode", _kodeTransaksiCtrl.text),
            _rowDetail("Durasi", "$durasi Jam"),
            const Divider(),
            Text("Rp $total", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            const Text("Pilih Metode Pembayaran:"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _paymentButton(ctx, "CASH", Icons.money, Colors.green, () => _processPayment(transData, total, "Cash")),
                _paymentButton(ctx, "QRIS", Icons.qr_code, Colors.blue, () => _processPayment(transData, total, "QRIS")),
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

  Future<void> _processPayment(Map<String, dynamic> transData, int total, String metode) async {
    setState(() => _isLoading = true);
    try {
      int transId = transData['id'] ?? transData['id_transaksi'];
      int slotId = transData['id_parkir_slot'] ?? 0;

      // 1. UPDATE TRANSAKSI SELESAI
      await ApiService.updateTransaksi(transId, widget.token, {
        "status": "Selesai",
        "total_biaya": total,
        "waktu_keluar": DateTime.now().toIso8601String(),
        "metode_pembayaran": metode // Pastikan backend terima field ini
      });

      // 2. KOSONGKAN SLOT PARKIR
      if (slotId != 0) {
        // Kita butuh data slot lama untuk update status doang
        // Asumsi data slot minimal ada 'nomor_slot'
        await ApiService.updateSlotParkir(slotId, widget.token, {
          "status": "Tersedia",
          "nomor_slot": transData['slot']?['nomor_slot'] ?? "X", // Fallback
          "lokasi": transData['slot']?['lokasi'] ?? "-"
        });
      }

      setState(() {
        _isLoading = false;
        _kodeTransaksiCtrl.clear();
      });
      _showMsg("Pembayaran Berhasil! Slot telah dikosongkan.", Colors.green);

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
          const Text("Data Pengguna", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _input(_namaUserCtrl, "Nama Pengguna", Icons.person),
          const SizedBox(height: 10),
          _input(_telpUserCtrl, "No. Telepon", Icons.phone, isNumber: true),
          
          const SizedBox(height: 24),
          const Text("Data Kendaraan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _input(_platCtrl, "Plat Nomor (Wajib)", Icons.confirmation_number_outlined),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _input(_merkCtrl, "Merk (Honda/Yamaha)", Icons.motorcycle)),
              const SizedBox(width: 10),
              Expanded(child: _input(_warnaCtrl, "Warna", Icons.color_lens)),
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
              hintText: "ID TRANSAKSI",
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
    _telpUserCtrl.clear();
    _platCtrl.clear();
    _merkCtrl.clear();
    _warnaCtrl.clear();
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
  }
}