import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Riwayat Transaksi'),
      body: const Center(child: Text('Halaman Riwayat Transaksi')),
    );
  }
}
