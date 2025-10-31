import 'package:flutter/material.dart';

class PageTransaksiAktif extends StatefulWidget {
  const PageTransaksiAktif({super.key});

  @override
  State<PageTransaksiAktif> createState() => _PageTransaksiAktifState();
}

class _PageTransaksiAktifState extends State<PageTransaksiAktif> {
  List<Map<String, String>> transaksiAktif = [
    {"motor": "Honda Vario", "slot": "A12", "jam_masuk": "09:00", "status": "Aktif"},
  ];

  void _hapusTransaksi(int index) {
    setState(() => transaksiAktif.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transaksiAktif.length,
      itemBuilder: (context, index) {
        final data = transaksiAktif[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.timer, color: Colors.orange),
            title: Text(data['motor']!),
            subtitle: Text('Slot: ${data['slot']} | Masuk: ${data['jam_masuk']} | Status: ${data['status']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _hapusTransaksi(index),
            ),
          ),
        );
      },
    );
  }
}
