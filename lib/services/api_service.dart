import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  // Pastikan URL ini benar
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
  // AUTH (Login via EMAIL)
  // ============================================================

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/login");
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({
          "email": email,       // KUNCI: Gunakan 'email'
          "password": password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "Error: $e"};
    }
  }

  // ... (Sisa fungsi lainnya seperti logout, checkIn, getPengguna, dll TETAP SAMA seperti sebelumnya)
  
  static Future<Map<String, dynamic>> logout(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/logout");
    final response = await http.post(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }

  // ... copy paste fungsi Operasional & CRUD lainnya dari jawaban sebelumnya ...
  // (Pastikan method CRUD master data tetap ada agar tidak error 'Member not found')
  // ...
  
  // 1. Check-In (Motor Masuk)
  static Future<Map<String, dynamic>> checkIn(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/parkir/checkin");
    final response = await http.post(url, headers: _headers(token: token), body: jsonEncode(data));
    return jsonDecode(response.body);
  }

  // 2. Cek Tiket
  static Future<Map<String, dynamic>> cekTiket(String token, String kodeTiket) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/parkir/cektiket/$kodeTiket");
    final response = await http.get(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }

  // 3. Checkout
  static Future<Map<String, dynamic>> checkOut(String token, String kodeTiket, String metode) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/parkir/checkout");
    final response = await http.post(url, headers: _headers(token: token), body: jsonEncode({
        "kode_tiket": kodeTiket,
        "metode_pembayaran": metode
    }));
    return jsonDecode(response.body);
  }
  
  // CRUD MASTER DATA (Agar tidak error di Page lain)
  static Future<List<dynamic>> getPengguna(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/pengguna");
    final response = await http.get(url, headers: _headers(token: token));
    if (response.statusCode == 200) return jsonDecode(response.body)['data'] ?? [];
    return [];
  }
  
  static Future<Map<String, dynamic>> createPengguna(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/pengguna");
    final response = await http.post(url, headers: _headers(token: token), body: jsonEncode(data));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updatePengguna(int id, String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/pengguna/$id");
    final response = await http.put(url, headers: _headers(token: token), body: jsonEncode(data));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deletePengguna(int id, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/pengguna/$id");
    final response = await http.delete(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getMotor(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/motors"); 
    final response = await http.get(url, headers: _headers(token: token));
    if (response.statusCode == 200) return jsonDecode(response.body)['data'] ?? [];
    return [];
  }
  
  static Future<Map<String, dynamic>> createMotor(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/motors"); 
    final response = await http.post(url, headers: _headers(token: token), body: jsonEncode(data));
    return jsonDecode(response.body);
  }
  
  static Future<Map<String, dynamic>> updateMotor(int id, String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/motors/$id"); 
    final response = await http.put(url, headers: _headers(token: token), body: jsonEncode(data));
    return jsonDecode(response.body);
  }
  
  static Future<Map<String, dynamic>> deleteMotor(int id, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/motors/$id"); 
    final response = await http.delete(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getTransaksi(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/dashboard"); 
    final response = await http.get(url, headers: _headers(token: token));
    if (response.statusCode == 200) return jsonDecode(response.body)['data'] ?? [];
    return [];
  }
  
  static Future<Map<String, dynamic>> createTransaksi(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/parkir/checkin"); 
    final response = await http.post(url, headers: _headers(token: token), body: jsonEncode(data));
    return jsonDecode(response.body);
  }
  
  static Future<Map<String, dynamic>> updateTransaksi(int id, String token, Map<String, dynamic> data) async {
     return {"success": false, "message": "Not implemented"};
  }
  
  static Future<Map<String, dynamic>> deleteTransaksi(int id, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/transaksi/$id"); 
    final response = await http.delete(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }
  
  static Future<List<dynamic>> getSlotParkir(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/slots"); 
    final response = await http.get(url, headers: _headers(token: token));
    if (response.statusCode == 200) return jsonDecode(response.body)['data'] ?? [];
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
}