class MotorModel {
  final int idMotor;
  final int idPengguna;
  final String merk;
  final String platNomor;
  final String warna;
  final int tahun;
  
  // Opsional: Untuk menampilkan nama pemilik di UI (dari relasi tabel pengguna)
  final String? namaPemilik;

  MotorModel({
    required this.idMotor,
    required this.idPengguna,
    required this.merk,
    required this.platNomor,
    required this.warna,
    required this.tahun,
    this.namaPemilik,
  });

  // Factory: Mengubah JSON (dari API) menjadi Object Dart
  factory MotorModel.fromJson(Map<String, dynamic> json) {
    return MotorModel(
      // Handle jika backend mengirim key 'id' atau 'id_motor'
      idMotor: _toInt(json['id_motor']) == 0 ? _toInt(json['id']) : _toInt(json['id_motor']),
      
      idPengguna: _toInt(json['id_pengguna']),
      
      merk: json['merk']?.toString() ?? '',
      
      platNomor: json['plat_nomor']?.toString() ?? '',
      
      warna: json['warna']?.toString() ?? '',
      
      tahun: _toInt(json['tahun']),
      
      // Ambil nama pemilik jika backend mengirim data relasi (nested object)
      namaPemilik: json['pengguna'] != null ? json['pengguna']['nama_lengkap'] : null,
    );
  }

  // Method: Mengubah Object Dart menjadi JSON (untuk dikirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id_pengguna': idPengguna,
      'merk': merk,
      'plat_nomor': platNomor,
      'warna': warna,
      'tahun': tahun,
    };
  }

  // --- HELPER FUNCTION (Agar parsing angka lebih aman) ---
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}