import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class PenggunaPage extends StatelessWidget {
  const PenggunaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Data Pengguna'),
      body: const Center(child: Text('Halaman Data Pengguna')),
    );
  }
}
