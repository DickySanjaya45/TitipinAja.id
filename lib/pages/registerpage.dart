import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  String namaLengkap = '';
  String alamat = '';
  String noTelepon = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password tidak cocok')));
      return;
    }

    setState(() => isLoading = true);
    await ApiService.register(
      namaLengkap: namaLengkap,
      alamat: alamat,
      noTelepon: noTelepon,
      email: email,
      password: password,
    );
    setState(() => isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Berhasil')));
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white, // Fallback background
      body: Stack(
        children: [
          // Background Blobs Decoration
          Positioned(top: -50, right: -50, child: _buildBlurCircle(200, primaryColor.withOpacity(0.3))),
          Positioned(bottom: 100, left: -50, child: _buildBlurCircle(250, Colors.tealAccent.withOpacity(0.2))),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
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

                          _buildInput("Nama Lengkap", Icons.person_outline, (v) => namaLengkap = v),
                          const SizedBox(height: 16),
                          _buildInput("Email", Icons.email_outlined, (v) => email = v, isEmail: true),
                          const SizedBox(height: 16),
                          _buildInput("No Telepon", Icons.phone_outlined, (v) => noTelepon = v, isNumber: true),
                          const SizedBox(height: 16),
                          _buildInput("Alamat", Icons.home_outlined, (v) => alamat = v),
                          const SizedBox(height: 16),
                          
                          // Password
                          TextFormField(
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                              ),
                            ),
                            onChanged: (v) => password = v,
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          TextFormField(
                            obscureText: !isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password',
                              prefixIcon: const Icon(Icons.lock_clock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
                              ),
                            ),
                            onChanged: (v) => confirmPassword = v,
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),

                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : register,
                              child: isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                                : const Text("DAFTAR"),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: Text("Sudah punya akun? Login", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
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

  Widget _buildInput(String label, IconData icon, Function(String) onChanged, {bool isEmail = false, bool isNumber = false}) {
    return TextFormField(
      keyboardType: isEmail ? TextInputType.emailAddress : (isNumber ? TextInputType.phone : TextInputType.text),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      onChanged: onChanged,
      validator: (v) => v == null || v.isEmpty ? '$label wajib diisi' : null,
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(color: Colors.transparent)),
    );
  }
}