class PenggunaModel {
  final int idPengguna;
  final String nama; // Ubah nama_lengkap -> nama
  final String noTelepon;
  final String alamat;

  PenggunaModel({
    required this.idPengguna,
    required this.nama,
    required this.noTelepon,
    required this.alamat,
  });

  factory PenggunaModel.fromJson(Map<String, dynamic> json) {
    return PenggunaModel(
      idPengguna: json['id_pengguna'] ?? 0,
      nama: json['nama']?.toString() ?? '', // Sesuai DB baru
      noTelepon: json['no_telepon']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengguna': idPengguna,
      'nama': nama,
      'no_telepon': noTelepon,
      'alamat': alamat,
    };
  }
}