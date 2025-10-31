import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti IP sesuai komputer kamu
  // Untuk Android Emulator: http://10.0.2.2:8000/api
  // Untuk Physical Device: http://IP_KOMPUTER_KAMU:8000/api
  // Untuk Web (Chrome): http://127.0.0.1:8000/api
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Login API
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Langsung decode body, biarkan Pengecekan 'success' di login_page
      return jsonDecode(response.body);

    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // Register API
  static Future<Map<String, dynamic>> register({
    required String namaLengkap,
    required String noTelepon,
    required String alamat,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama_lengkap': namaLengkap,
          'no_telepon': noTelepon,
          'alamat': alamat,
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // --- FUNGSI-FUNGSI BARU UNTUK DASHBOARD ---

  // FUNGSI UPDATE PENGGUNA (BARU)
  static Future<Map<String, dynamic>> updateUser(
      int userId, String token, Map<String, String> data) async {
    final url = Uri.parse('$baseUrl/pengguna/$userId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Kirim token
        },
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // FUNGSI DELETE PENGGUNA (BARU)
  static Future<Map<String, dynamic>> deleteUser(int userId, String token) async {
    final url = Uri.parse('$baseUrl/pengguna/$userId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Kirim token
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // FUNGSI LOGOUT (BARU)
  static Future<Map<String, dynamic>> logout(String token) async {
    final url = Uri.parse('$baseUrl/logout');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Kirim token
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // FUNGSI GET ACTIVITIES (BARU)
  // Mengambil daftar aktivitas pengguna; endpoint ini diasumsikan tersedia di backend
  static Future<Map<String, dynamic>> getActivities(String token) async {
    final url = Uri.parse('$baseUrl/aktivitas');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }
}
