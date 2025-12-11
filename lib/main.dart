import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/login_page.dart'; 

void main() {
  // Set status bar transparan agar tampilan lebih modern
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const TitipinAjaApp());
}

class TitipinAjaApp extends StatelessWidget {
  const TitipinAjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TitipinAja Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Warna tema utama (Ungu)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B2B9C),
          primary: const Color(0xFF5B2B9C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5B2B9C),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const LoginPage(), // Langsung ke Login Admin
    );
  }
}