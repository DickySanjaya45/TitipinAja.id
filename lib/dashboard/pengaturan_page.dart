import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  // Data dummy pengaturan
  List<Map<String, dynamic>> daftarPengaturan = [
    {'id': 1, 'nama': 'Notifikasi', 'status': true},
    {'id': 2, 'nama': 'Mode Gelap', 'status': false},
  ];

  void _toggleStatus(int index) {
    setState(() {
      daftarPengaturan[index]['status'] = !daftarPengaturan[index]['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pengaturan'),
      body: ListView.builder(
        itemCount: daftarPengaturan.length,
        itemBuilder: (context, index) {
          final item = daftarPengaturan[index];
          return SwitchListTile(
            title: Text(item['nama']),
            value: item['status'],
            onChanged: (val) => _toggleStatus(index),
          );
        },
      ),
    );
  }
}
