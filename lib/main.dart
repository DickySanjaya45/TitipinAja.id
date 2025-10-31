import 'package:flutter/material.dart';
import 'login_page.dart';
import 'pages/registerpage.dart';
import 'pages/homepage.dart';
import 'dashboard/dashboard_admin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistem Penitipan Motor',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboardAdmin': (context) => const DashboardAdmin(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
