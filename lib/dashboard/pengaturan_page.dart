import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pengaturan'),
      body: const Center(child: Text('Halaman Pengaturan')),
    );
  }
}
