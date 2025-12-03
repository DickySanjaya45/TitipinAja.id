class MotorModel {
  final int idMotor;
  final int idPengguna;
  final String merk;
  final String platNomor;
  final String warna;
  final int tahun;

  MotorModel({
    required this.idMotor,
    required this.idPengguna,
    required this.merk,
    required this.platNomor,
    required this.warna,
    required this.tahun,
  });

  // Factory untuk mengubah JSON dari API menjadi Object MotorModel
  factory MotorModel.fromJson(Map<String, dynamic> json) {
    return MotorModel(
      idMotor: json['id_motor'] ?? json['id'] ?? 0,
      idPengguna: int.tryParse(json['id_pengguna'].toString()) ?? 0,
      merk: json['merk'] ?? '',
      platNomor: json['plat_nomor'] ?? '',
      warna: json['warna'] ?? '',
      tahun: int.tryParse(json['tahun'].toString()) ?? 0,
    );
  }

  // Mengubah Object menjadi JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'id_pengguna': idPengguna,
      'merk': merk,
      'plat_nomor': platNomor,
      'warna': warna,
      'tahun': tahun,
    };
  }
}