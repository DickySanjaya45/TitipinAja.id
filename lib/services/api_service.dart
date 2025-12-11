import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  // Pastikan URL ini sesuai dengan URL Railway Anda
  static const String baseUrl = "https://titipinajaid-backend.up.railway.app/api";
}

class ApiService {
  
  static Map<String, String> _headers({String? token}) {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  // ============================================================
  // AUTH (PETUGAS)
  // ============================================================

  // Login menggunakan Username & Password
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/login");

    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({
          "username": username, // Backend sekarang butuh username
          "password": password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "Koneksi Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> logout(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/logout");
    final response = await http.post(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }

  // ============================================================
  // OPERASIONAL PARKIR (INTI SISTEM)
  // ============================================================

  // 1. Dashboard (List Kendaraan Masuk)
  static Future<List<dynamic>> getDashboard(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/dashboard");
    final response = await http.get(url, headers: _headers(token: token));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    return [];
  }

  // 2. Check-In (Motor Masuk)
  static Future<Map<String, dynamic>> checkIn(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/parkir/checkin");
    final response = await http.post(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode(data)
    );
    return jsonDecode(response.body);
  }

  // 3. Cek Tiket (Scan QR)
  static Future<Map<String, dynamic>> cekTiket(String token, String kodeTiket) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/parkir/cektiket/$kodeTiket");
    final response = await http.get(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }

  // 4. Check-Out (Bayar & Keluar)
  static Future<Map<String, dynamic>> checkOut(String token, String kodeTiket, String metode) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/parkir/checkout");
    final response = await http.post(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode({
        "kode_tiket": kodeTiket,
        "metode_pembayaran": metode
      })
    );
    return jsonDecode(response.body);
  }

  // ============================================================
  // MANAJEMEN DATA (CRUD ADMIN)
  // ============================================================

  // --- SLOT PARKIR ---
  static Future<List<dynamic>> getSlotParkir(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/slots"); // Endpoint baru: /slots
    final response = await http.get(url, headers: _headers(token: token));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> createSlotParkir(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/slots");
    final response = await http.post(url, headers: _headers(token: token), body: jsonEncode(data));
    return jsonDecode(response.body);
  }
  
  static Future<Map<String, dynamic>> updateSlotParkir(int id, String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/slots/$id");
    final response = await http.put(url, headers: _headers(token: token), body: jsonEncode(data));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteSlotParkir(int id, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/slots/$id");
    final response = await http.delete(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }

  // --- PENGGUNA ---
  static Future<List<dynamic>> getPengguna(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/pengguna");
    final response = await http.get(url, headers: _headers(token: token));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    return [];
  }

  // --- REPORT/RIWAYAT ---
  // Anda bisa menggunakan endpoint /dashboard atau buat endpoint khusus riwayat di backend
}