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

  factory PenggunaModel.fromJson(Map<String, dynamic> json) {
    return PenggunaModel(
      idPengguna: json['id_pengguna'] ?? json['id'] ?? 0,
      namaLengkap: json['nama_lengkap'] ?? '',
      email: json['email'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      alamat: json['alamat'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengguna': idPengguna,
      'nama_lengkap': namaLengkap,
      'email': email,
      'no_telepon': noTelepon,
      'alamat': alamat,
    };
  }
}