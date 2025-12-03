class PenggunaModel {
  final int idPengguna;
  final String namaLengkap;
  final String email;
  final String noTelepon;
  final String alamat;

  PenggunaModel({
    required this.idPengguna,
    required this.namaLengkap,
    required this.email,
    required this.noTelepon,
    required this.alamat,
  });

  // Factory: Mengubah JSON (dari API) menjadi Object Dart
  factory PenggunaModel.fromJson(Map<String, dynamic> json) {
    return PenggunaModel(
      // Cek 'id_pengguna' dulu, kalau 0/null baru cek 'id'
      idPengguna: _toInt(json['id_pengguna']) != 0 
          ? _toInt(json['id_pengguna']) 
          : _toInt(json['id']),
      
      namaLengkap: json['nama_lengkap']?.toString() ?? '',
      
      email: json['email']?.toString() ?? '',
      
      // No Telepon kadang dikirim sebagai angka oleh backend, jadi perlu toString()
      noTelepon: json['no_telepon']?.toString() ?? '',
      
      alamat: json['alamat']?.toString() ?? '',
    );
  }

  // Method: Mengubah Object Dart menjadi JSON (untuk dikirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id_pengguna': idPengguna,
      'nama_lengkap': namaLengkap,
      'email': email,
      'no_telepon': noTelepon,
      'alamat': alamat,
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