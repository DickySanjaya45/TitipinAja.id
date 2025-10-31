import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class PembayaranPage extends StatelessWidget {
  const PembayaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pembayaran'),
      body: const Center(child: Text('Halaman Pembayaran')),
    );
  }
}
