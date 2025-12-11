import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../dashboard/dashboard_admin.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController(); // Ganti email jadi username
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;

  Future<void> _handleLogin() async {
    if (_usernameCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username dan Password wajib diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil API Login
      final response = await ApiService.login(
        _usernameCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Cek Token (Backend baru mengembalikan 'access_token')
      if (response.containsKey('access_token')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardAdmin(
              token: response['access_token'],
              adminData: response['data'], // Data petugas
            ),
          ),
        );
      } else {
        _showError(response['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError("Gagal terhubung ke server.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B2B9C),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.local_parking_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text("ADMIN PARKIR", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameCtrl, // Username
                        decoration: const InputDecoration(
                          labelText: "Username",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B2B9C),
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text("LOGIN"),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}