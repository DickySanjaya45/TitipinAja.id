import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  // URL Backend Railway
  static const String baseUrl = "https://titipinajaid-backend.up.railway.app/api";
}

class ApiService {
  
  // Helper untuk Header standar (Otomatis pasang Token jika ada)
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
  // AUTH
  // ============================================================

  /// POST /api/login
  static Future<Map<String, dynamic>> login(String email, String password, String role) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/login");

    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({
          "email": email,
          "password": password,
          "role": role, // WAJIB: 'admin' atau 'user'
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Koneksi Error: $e"};
    }
  }

  /// POST /api/logout
  static Future<Map<String, dynamic>> logout(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/logout");
    try {
      final response = await http.post(
        url,
        headers: _headers(token: token),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Gagal Logout"};
    }
  }

  /// POST /api/register
  static Future<Map<String, dynamic>> register({
    required String namaLengkap,
    required String email,
    required String password,
    required String alamat,
    required String noTelepon,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/register");

    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        "nama_lengkap": namaLengkap,
        "email": email,
        "password": password,
        "alamat": alamat,
        "no_telepon": noTelepon,
      }),
    );

    return jsonDecode(response.body);
  }

  /// GET /api/profile
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/profile");
    final response = await http.get(
      url,
      headers: _headers(token: token),
    );
    return jsonDecode(response.body);
  }

  // ============================================================
  // PENGGUNA (CRUD)
  // ============================================================

  /// GET /api/pengguna
  static Future<List<dynamic>> getPengguna(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/pengguna");

    final response = await http.get(
      url,
      headers: _headers(token: token),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? []; 
    } else {
      return [];
    }
  }

  /// POST /api/pengguna
  static Future<Map<String, dynamic>> createPengguna(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/pengguna");
    final response = await http.post(
      url,
      headers: _headers(token: token),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  /// PUT /api/pengguna/{id}
  static Future<Map<String, dynamic>> updatePengguna(int id, String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/pengguna/$id");
    final response = await http.put(
      url,
      headers: _headers(token: token),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  /// DELETE /api/pengguna/{id}
  static Future<Map<String, dynamic>> deletePengguna(int id, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/pengguna/$id");
    final response = await http.delete(
      url,
      headers: _headers(token: token),
    );
    return jsonDecode(response.body);
  }

  // ============================================================
  // AKTIVITAS
  // ============================================================

  static Future<List<dynamic>> getAktivitas(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/aktivitas");
    final response = await http.get(url, headers: _headers(token: token));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    return [];
  }

  // ============================================================
  // MOTOR (CRUD)
  // ============================================================

  static Future<List<dynamic>> getMotor(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/motor");
    final response = await http.get(url, headers: _headers(token: token));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> createMotor(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/motor");
    final response = await http.post(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode(data)
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateMotor(int id, String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/motor/$id");
    final response = await http.put(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode(data)
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteMotor(int id, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/motor/$id");
    final response = await http.delete(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }

  // ============================================================
  // SLOT PARKIR (CRUD)
  // ============================================================

  // Asumsi endpoint di backend: /parkir-slot atau /parkir_slot
  // Sesuaikan dengan routes/api.php Anda (misal: Route::apiResource('parkir-slot', ...))
  static const String _parkirEndpoint = "parkir_slot"; 

  static Future<List<dynamic>> getSlotParkir(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/$_parkirEndpoint");
    final response = await http.get(url, headers: _headers(token: token));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> createSlotParkir(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/$_parkirEndpoint");
    final response = await http.post(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode(data)
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateSlotParkir(int id, String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/$_parkirEndpoint/$id");
    final response = await http.put(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode(data)
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteSlotParkir(int id, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/$_parkirEndpoint/$id");
    final response = await http.delete(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }

  // ============================================================
  // MEMBER (CRUD)
  // ============================================================

  static Future<List<dynamic>> getMember(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/member"); // Sesuaikan route backend
    final response = await http.get(url, headers: _headers(token: token));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> createMember(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/member");
    final response = await http.post(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode(data)
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateMember(int id, String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/member/$id");
    final response = await http.put(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode(data)
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteMember(int id, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/member/$id");
    final response = await http.delete(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }

  // ============================================================
  // PETUGAS (CRUD)
  // ============================================================

  static Future<List<dynamic>> getPetugas(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/petugas");
    final response = await http.get(url, headers: _headers(token: token));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> createPetugas(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/petugas");
    final response = await http.post(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode(data)
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updatePetugas(int id, String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/petugas/$id");
    final response = await http.put(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode(data)
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deletePetugas(int id, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/petugas/$id");
    final response = await http.delete(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }

  // ============================================================
  // TARIF
  // ============================================================

  static Future<List<dynamic>> getTarif(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/tarif");
    final response = await http.get(url, headers: _headers(token: token));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    return [];
  }

  // ============================================================
  // TRANSAKSI (CRUD) - WAJIB ADA untuk PembayaranPage
  // ============================================================

  static Future<List<dynamic>> getTransaksi(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/transaksi");
    final response = await http.get(url, headers: _headers(token: token));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    return [];
  }

  // Menambahkan fungsi CREATE Transaksi
  static Future<Map<String, dynamic>> createTransaksi(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/transaksi");
    final response = await http.post(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode(data)
    );
    return jsonDecode(response.body);
  }

  // Menambahkan fungsi UPDATE Transaksi
  static Future<Map<String, dynamic>> updateTransaksi(int id, String token, Map<String, dynamic> data) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/transaksi/$id");
    final response = await http.put(
      url, 
      headers: _headers(token: token), 
      body: jsonEncode(data)
    );
    return jsonDecode(response.body);
  }

  // Menambahkan fungsi DELETE Transaksi
  static Future<Map<String, dynamic>> deleteTransaksi(int id, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/transaksi/$id");
    final response = await http.delete(url, headers: _headers(token: token));
    return jsonDecode(response.body);
  }
}