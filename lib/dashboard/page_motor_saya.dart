import 'package:flutter/material.dart';

class PageMotorSaya extends StatefulWidget {
  const PageMotorSaya({super.key});

  @override
  State<PageMotorSaya> createState() => _PageMotorSayaState();
}

class _PageMotorSayaState extends State<PageMotorSaya> {
  final List<Map<String, String>> motorList = [
    {"nama": "Honda Vario", "plat": "B 1234 XYZ", "tahun": "2021"},
    {"nama": "Yamaha NMAX", "plat": "D 5678 ABC", "tahun": "2020"},
  ];

  final TextEditingController namaController = TextEditingController();
  final TextEditingController platController = TextEditingController();
  final TextEditingController tahunController = TextEditingController();

  void _tambahMotor() {
    if (namaController.text.isEmpty ||
        platController.text.isEmpty ||
        tahunController.text.isEmpty) return;

    setState(() {
      motorList.add({
        "nama": namaController.text,
        "plat": platController.text,
        "tahun": tahunController.text,
      });
    });

    namaController.clear();
    platController.clear();
    tahunController.clear();
    Navigator.pop(context);
  }

  void _hapusMotor(int index) {
    setState(() {
      motorList.removeAt(index);
    });
  }

  void _tampilkanFormTambah() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Motor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaController, decoration: const InputDecoration(labelText: 'Nama Motor')),
            TextField(controller: platController, decoration: const InputDecoration(labelText: 'Plat Nomor')),
            TextField(controller: tahunController, decoration: const InputDecoration(labelText: 'Tahun')),
          ],
        ),
        actions: [
          TextButton(onPressed: _tambahMotor, child: const Text('Simpan')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: motorList.length,
        itemBuilder: (context, index) {
          final motor = motorList[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.motorcycle, color: Colors.blue),
              title: Text(motor['nama']!),
              subtitle: Text('Plat: ${motor['plat']} | Tahun: ${motor['tahun']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _hapusMotor(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tampilkanFormTambah,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
