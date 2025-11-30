import 'dart:async';

class ApiService {
  
  // --- MOCK LOGIN ---
  // Pura-pura login sukses dan balikin token palsu
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulasi loading 1 detik
    await Future.delayed(const Duration(seconds: 1));
    
    // Ceritanya login selalu berhasil
    return {
      'status': true,
      'token': 'token_palsu_123456',
      'user': {
        'id': 1,
        'name': 'User Dummy',
        'email': email,
      }
    };
  }

  // --- MOCK REGISTER ---
  static Future<Map<String, dynamic>> register({
    required String namaLengkap, 
    required String email, 
    required String password,
    required String alamat,
    required String noTelepon,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'message': 'Registrasi Berhasil (Mode Dummy)',
    };
  }

  // --- MOCK LOGOUT ---
  static Future<void> logout(String token) async {
    // Gak ngapa-ngapain, anggap aja sukses logout
    return;
  }

  // --- MOCK GET ACTIVITIES (Untuk Dashboard) ---
  static Future<List<Map<String, dynamic>>> getActivities(String token) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Ini data pura-pura yang akan muncul di dashboard kamu
    return [
      {
        "id": 1,
        "title": "Parkir Vario",
        "status": "Sedang Parkir",
        "price": 5000,
        "date": "2023-11-30"
      },
      {
        "id": 2,
        "title": "Cuci Motor",
        "status": "Selesai",
        "price": 15000,
        "date": "2023-11-29"
      },
    ];
  }

  // --- MOCK UPDATE USER ---
  static Future<Map<String, dynamic>> updateUser(int userId, String token, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'message': 'Profil berhasil diperbarui',
      'data': {
        'id': userId,
        'nama_lengkap': data['nama_lengkap'] ?? '',
        'email': data['email'] ?? '',
        'no_telepon': data['no_telepon'] ?? '',
        'alamat': data['alamat'] ?? '',
      }
    };
  }

  // --- MOCK DELETE USER ---
  static Future<Map<String, dynamic>> deleteUser(int userId, String token) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'message': 'Akun berhasil dihapus'
    };
  }
}