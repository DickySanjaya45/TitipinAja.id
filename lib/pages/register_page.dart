import 'dart:ui'; // Untuk BackdropFilter
import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Pastikan path ini benar
import 'login_page.dart'; // Import Login Page

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk mengambil input user
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Hapus controller saat halaman ditutup agar memori tidak bocor
  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- LOGIKA REGISTRASI ---
  Future<void> _handleRegister() async {
    // 1. Validasi Form Frontend
    if (!_formKey.currentState!.validate()) return;

    // 2. Validasi Password Match Manual
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan Konfirmasi Password tidak sama'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Panggil API Service
      final response = await ApiService.register(
        namaLengkap: _namaController.text.trim(),
        email: _emailController.text.trim(),
        noTelepon: _phoneController.text.trim(),
        alamat: _alamatController.text.trim(),
        password: _passwordController.text,
      );

      // Matikan loading
      if (!mounted) return;
      setState(() => _isLoading = false);

      // 4. Cek Response dari Backend
      if (response['success'] == true) {
        // --- SUKSES ---
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi Berhasil! Silakan Login.'),
            backgroundColor: Colors.green,
          ),
        );

        // Arahkan ke halaman Login dan hapus stack register
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      } else {
        // --- GAGAL (Misal: Email sudah terpakai) ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Registrasi Gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // --- ERROR KONEKSI ---
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil warna utama dari tema aplikasi
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BACKGROUND DECORATION (Blobs)
          Positioned(
            top: -50,
            right: -50,
            child: _buildBlurCircle(200, primaryColor.withAlpha((0.3 * 255).round())),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: _buildBlurCircle(250, Colors.tealAccent.withAlpha((0.2 * 255).round())),
          ),

          // 2. FORM CONTENT (Glass Card)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Reduced for better performance
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withAlpha((0.5 * 255).round())),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha((0.1 * 255).round()),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add_rounded, size: 50, color: primaryColor),
                          const SizedBox(height: 10),
                          Text(
                            "Buat Akun Baru",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Input Fields
                          _buildTextField(
                            controller: _namaController,
                            label: "Nama Lengkap",
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emailController,
                            label: "Email",
                            icon: Icons.email_outlined,
                            inputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _phoneController,
                            label: "No Telepon",
                            icon: Icons.phone_outlined,
                            inputType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _alamatController,
                            label: "Alamat",
                            icon: Icons.home_outlined,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (v) => (v == null || v.length < 6) ? 'Min 6 karakter' : null,
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password',
                              prefixIcon: const Icon(Icons.lock_clock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),

                          const SizedBox(height: 30),

                          // Tombol Daftar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("DAFTAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Link ke Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Sudah punya akun? "),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                                child: Text(
                                  "Login",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk Input Text Biasa
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (v) => v == null || v.trim().isEmpty ? '$label wajib diisi' : null,
    );
  }

  // Helper Widget untuk Dekorasi Bulat Blur
  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}