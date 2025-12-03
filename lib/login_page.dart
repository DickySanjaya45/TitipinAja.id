import 'dart:ui'; // Diperlukan untuk BackdropFilter
import 'package:flutter/material.dart';
import 'dashboard/dashboard_admin.dart';
import 'dashboard/dashboard_user.dart';
import 'pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String selectedRole = "User";

  void _login() async {
    // Logika Login (Sama seperti sebelumnya)
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi semua data')));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300)); // Simulasi singkat
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (selectedRole == "Admin") {
      if (email == 'admin@gmail.com' && password == '12345') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardAdmin(
              token: 'dummy_token',
              adminData: {'nama_petugas': 'Administrator', 'email': email},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Gagal')));
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardUser(
            userData: {'username': email.split('@')[0], 'email': email},
            token: 'dummy',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna tema lokal
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BACKGROUND DECORATION (Blobs)
          Positioned(
            top: -100,
            left: -50,
            child: _buildBlurCircle(300, primaryColor.withAlpha((0.4 * 255).round())),
          ),
          Positioned(
            top: 100,
            right: -80,
            child: _buildBlurCircle(250, const Color(0xFF00C897).withAlpha((0.3 * 255).round())),
          ),
          Positioned(
            bottom: -50,
            left: 20,
            child: _buildBlurCircle(200, Colors.orangeAccent.withAlpha((0.2 * 255).round())),
          ),

          // 2. MAIN CONTENT (Glass Card)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Reduced blur for performance
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.7 * 255).round()), // Putih transparan
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withAlpha((0.5 * 255).round())),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha((0.2 * 255).round()),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo / Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha((0.1 * 255).round()),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.local_parking_rounded, size: 48, color: primaryColor),
                        ),
                        const SizedBox(height: 20),
                        
                        Text(
                          "TitipinAja",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Masuk untuk mengelola parkir Anda",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 32),

                        // Form Fields
                        _buildRoleSelector(),
                        const SizedBox(height: 16),
                        
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Email Address",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                : const Text("MASUK"),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Belum punya akun? ", style: TextStyle(color: Colors.grey.shade600)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                              child: Text(
                                "Daftar",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
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

  // Widget Dekorasi Bulat Blur
  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  // Widget Pilihan Role Custom
  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ["User", "Admin"].map((role) {
          final isSelected = selectedRole == role;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedRole = role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 4, spreadRadius: 1)]
                      : [],
                ),
                child: Text(
                  role,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}