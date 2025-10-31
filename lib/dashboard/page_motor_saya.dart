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

  // Tambah motor
  void _tambahMotor() {
    namaController.clear();
    platController.clear();
    tahunController.clear();

    _showFormDialog(isEdit: false);
  }

  // Edit motor
  void _editMotor(int index) {
    final motor = motorList[index];
    namaController.text = motor["nama"]!;
    platController.text = motor["plat"]!;
    tahunController.text = motor["tahun"]!;

    _showFormDialog(isEdit: true, index: index);
  }

  // Hapus motor dengan konfirmasi
  void _hapusMotor(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Motor"),
        content: Text(
          "Apakah kamu yakin ingin menghapus motor '${motorList[index]['nama']}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                motorList.removeAt(index);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Motor berhasil dihapus"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // Form dialog (Tambah / Edit)
  void _showFormDialog({bool isEdit = false, int? index}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit Motor" : "Tambah Motor"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Motor'),
            ),
            TextField(
              controller: platController,
              decoration: const InputDecoration(labelText: 'Plat Nomor'),
            ),
            TextField(
              controller: tahunController,
              decoration: const InputDecoration(labelText: 'Tahun'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (namaController.text.isEmpty ||
                  platController.text.isEmpty ||
                  tahunController.text.isEmpty) {
                return;
              }

              setState(() {
                if (isEdit && index != null) {
                  motorList[index] = {
                    "nama": namaController.text,
                    "plat": platController.text,
                    "tahun": tahunController.text,
                  };
                } else {
                  motorList.add({
                    "nama": namaController.text,
                    "plat": platController.text,
                    "tahun": tahunController.text,
                  });
                }
              });

              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motor Saya"),
        backgroundColor: Colors.blueAccent,
      ),
      body: motorList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada motor terdaftar.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: motorList.length,
              itemBuilder: (context, index) {
                final motor = motorList[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.motorcycle, color: Colors.blue),
                    title: Text(motor['nama']!),
                    subtitle:
                        Text('Plat: ${motor['plat']} | Tahun: ${motor['tahun']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editMotor(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapusMotor(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahMotor,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
