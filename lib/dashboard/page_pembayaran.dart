import 'package:flutter/material.dart';

class PagePembayaran extends StatefulWidget {
  const PagePembayaran({super.key});

  @override
  State<PagePembayaran> createState() => _PagePembayaranState();
}

class _PagePembayaranState extends State<PagePembayaran> {
  final List<Map<String, String>> pembayaranList = [
    {"motor": "Honda Vario", "jumlah": "Rp 10.000", "metode": "Tunai", "tanggal": "31-10-2025"},
  ];

  final motorController = TextEditingController();
  final jumlahController = TextEditingController();
  final metodeController = TextEditingController();

  void _tambahPembayaran() {
    setState(() {
      pembayaranList.add({
        "motor": motorController.text,
        "jumlah": jumlahController.text,
        "metode": metodeController.text,
        "tanggal": DateTime.now().toString().split(' ')[0],
      });
    });
    Navigator.pop(context);
  }

  void _showTambahForm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Pembayaran"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: motorController, decoration: const InputDecoration(labelText: "Motor")),
            TextField(controller: jumlahController, decoration: const InputDecoration(labelText: "Jumlah")),
            TextField(controller: metodeController, decoration: const InputDecoration(labelText: "Metode")),
          ],
        ),
        actions: [
          TextButton(onPressed: _tambahPembayaran, child: const Text("Simpan")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pembayaranList.length,
        itemBuilder: (context, index) {
          final bayar = pembayaranList[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.payment, color: Colors.green),
              title: Text(bayar['motor']!),
              subtitle: Text('Jumlah: ${bayar['jumlah']} | Metode: ${bayar['metode']}'),
              trailing: Text(bayar['tanggal']!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showTambahForm, child: const Icon(Icons.add)),
    );
  }
}
