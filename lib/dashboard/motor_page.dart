import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class MotorPage extends StatefulWidget {
  const MotorPage({super.key});

  @override
  State<MotorPage> createState() => _MotorPageState();
}

class _MotorPageState extends State<MotorPage> {
  // Data dummy motor
  List<Map<String, String>> daftarMotor = [
    {'id': '1', 'plat': 'L 1234 AB', 'merek': 'Honda Beat', 'warna': 'Merah'},
    {'id': '2', 'plat': 'W 5678 CD', 'merek': 'Yamaha Nmax', 'warna': 'Hitam'},
  ];

  final TextEditingController platController = TextEditingController();
  final TextEditingController merekController = TextEditingController();
  final TextEditingController warnaController = TextEditingController();

  // Tambah atau edit data motor
  void _showForm({Map<String, String>? motor}) {
    if (motor != null) {
      platController.text = motor['plat']!;
      merekController.text = motor['merek']!;
      warnaController.text = motor['warna']!;
    } else {
      platController.clear();
      merekController.clear();
      warnaController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(motor == null ? 'Tambah Motor' : 'Edit Motor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: platController,
                decoration: const InputDecoration(labelText: 'Nomor Polisi'),
              ),
              TextField(
                controller: merekController,
                decoration: const InputDecoration(labelText: 'Merek Motor'),
              ),
              TextField(
                controller: warnaController,
                decoration: const InputDecoration(labelText: 'Warna'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (platController.text.isEmpty ||
                  merekController.text.isEmpty ||
                  warnaController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua field harus diisi!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              setState(() {
                if (motor == null) {
                  daftarMotor.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'plat': platController.text,
                    'merek': merekController.text,
                    'warna': warnaController.text,
                  });
                } else {
                  motor['plat'] = platController.text;
                  motor['merek'] = merekController.text;
                  motor['warna'] = warnaController.text;
                }
              });

              Navigator.pop(context);
            },
            child: Text(motor == null ? 'Simpan' : 'Update'),
          ),
        ],
      ),
    );
  }

  // Hapus motor
  void _hapusMotor(Map<String, String> motor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Yakin ingin menghapus motor ${motor['plat']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                daftarMotor.remove(motor);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data motor berhasil dihapus!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Data Motor'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: daftarMotor.isEmpty
            ? const Center(child: Text('Belum ada data motor'))
            : ListView.builder(
                itemCount: daftarMotor.length,
                itemBuilder: (context, index) {
                  final motor = daftarMotor[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.motorcycle, color: Colors.deepPurple),
                      title: Text(motor['merek']!),
                      subtitle: Text(
                        '${motor['plat']} • ${motor['warna']}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showForm(motor: motor),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapusMotor(motor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
