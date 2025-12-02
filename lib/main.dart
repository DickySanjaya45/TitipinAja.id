import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';
import 'dashboard/dashboard_user.dart';
import 'dashboard/dashboard_admin.dart';

void main() {
  // Mengatur status bar agar transparan dan icon gelap/terang menyesuaikan
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, 
    statusBarBrightness: Brightness.light, // Untuk iOS
  ));
  runApp(const TitipinAjaApp());
}

class TitipinAjaApp extends StatelessWidget {
  const TitipinAjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TitipinAja.id',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Light Grey-Blue Background
        fontFamily: 'Poppins', // Pastikan font terdaftar di pubspec.yaml jika ada
        
        // Skema Warna
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // Modern Indigo/Purple
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF00C897), // Soft Teal Accent
          surface: Colors.white,
          background: const Color(0xFFF5F7FA),
        ),

        // Style Input Global (Clean & Soft)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIconColor: Colors.grey.shade400,
        ),

        // Style Button Global (Gradient Style Placeholder)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: const Color(0xFF6C63FF).withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),

      // Routing
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard_admin': (context) => const DashboardAdmin(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard_user') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => DashboardUser(
              userData: args?['userData'] ?? {},
              token: args?['token'] ?? '',
            ),
          );
        }
        return null;
      },
    );
  }
}