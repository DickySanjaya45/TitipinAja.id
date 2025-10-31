import 'package:flutter/material.dart';

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

  // Simulasi database sementara
  final List<Map<String, String>> dummyUsers = [
    {
      'email': 'admin@gmail.com',
      'password': '12345',
      'nama_lengkap': 'Admin Utama',
      'no_telepon': '08123456789',
      'alamat': 'Jl. Bunga No.1'
    },
  ];

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi tidak cocok')),
      );
      return;
    }

    final existingUser = dummyUsers.any((u) => u['email'] == email);
    if (existingUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email sudah digunakan')),
      );
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    dummyUsers.add({
      'nama_lengkap': namaLengkap,
      'alamat': alamat,
      'no_telepon': noTelepon,
      'email': email,
      'password': password,
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registrasi berhasil, selamat datang $namaLengkap!')),
    );

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Registrasi Pengguna'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add, size: 60, color: Colors.deepPurple),
                    const SizedBox(height: 24),

                    // Nama Lengkap
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => namaLengkap = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Masukkan nama lengkap' : null,
                    ),
                    const SizedBox(height: 16),

                    // Alamat
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (v) => alamat = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Masukkan alamat' : null,
                    ),
                    const SizedBox(height: 16),

                    // No Telepon
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'No Telepon',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => noTelepon = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Masukkan nomor telepon' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => email = v,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Masukkan email';
                        } else if (!v.contains('@')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !isPasswordVisible,
                      onChanged: (v) => password = v,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Masukkan password' : null,
                    ),
                    const SizedBox(height: 16),

                    // Konfirmasi Password
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !isConfirmPasswordVisible,
                      onChanged: (v) => confirmPassword = v,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Masukkan konfirmasi password'
                          : null,
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : register,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Daftar'),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Sudah punya akun? Login di sini',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
