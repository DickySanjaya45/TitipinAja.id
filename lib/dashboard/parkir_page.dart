import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class ParkirPage extends StatefulWidget {
  const ParkirPage({super.key});

  @override
  State<ParkirPage> createState() => _ParkirPageState();
}

class _ParkirPageState extends State<ParkirPage> {
  // Data dummy untuk slot parkir
  List<Map<String, String>> daftarParkir = [
    {'id': '1', 'nomor': 'A1', 'lokasi': 'Area Utara', 'status': 'Tersedia'},
    {'id': '2', 'nomor': 'A2', 'lokasi': 'Area Selatan', 'status': 'Terisi'},
  ];

  final TextEditingController nomorController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  String statusSelected = 'Tersedia';

  // Form tambah/edit data slot parkir
  void _showForm({Map<String, String>? slot}) {
    if (slot != null) {
      nomorController.text = slot['nomor']!;
      lokasiController.text = slot['lokasi']!;
      statusSelected = slot['status']!;
    } else {
      nomorController.clear();
      lokasiController.clear();
      statusSelected = 'Tersedia';
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(slot == null ? 'Tambah Slot Parkir' : 'Edit Slot Parkir'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomorController,
                decoration: const InputDecoration(labelText: 'Nomor Slot'),
              ),
              TextField(
                controller: lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi Parkir'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: statusSelected,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Tersedia', child: Text('Tersedia')),
                  DropdownMenuItem(value: 'Terisi', child: Text('Terisi')),
                ],
                onChanged: (value) {
                  setState(() {
                    statusSelected = value!;
                  });
                },
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
              if (nomorController.text.isEmpty ||
                  lokasiController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua field harus diisi!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              setState(() {
                if (slot == null) {
                  // Tambah slot baru
                  daftarParkir.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'nomor': nomorController.text,
                    'lokasi': lokasiController.text,
                    'status': statusSelected,
                  });
                } else {
                  // Update slot
                  slot['nomor'] = nomorController.text;
                  slot['lokasi'] = lokasiController.text;
                  slot['status'] = statusSelected;
                }
              });

              Navigator.pop(context);
            },
            child: Text(slot == null ? 'Simpan' : 'Update'),
          ),
        ],
      ),
    );
  }

  // Hapus slot parkir
  void _hapusSlot(Map<String, String> slot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Slot Parkir'),
        content: Text('Yakin ingin menghapus slot ${slot['nomor']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                daftarParkir.remove(slot);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Slot parkir berhasil dihapus!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Slot Parkir'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: daftarParkir.isEmpty
            ? const Center(child: Text('Belum ada data slot parkir'))
            : ListView.builder(
                itemCount: daftarParkir.length,
                itemBuilder: (context, index) {
                  final slot = daftarParkir[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        slot['status'] == 'Terisi'
                            ? Icons.local_parking_rounded
                            : Icons.directions_car_outlined,
                        color: slot['status'] == 'Terisi'
                            ? Colors.red
                            : Colors.green,
                      ),
                      title: Text(
                        'Slot ${slot['nomor']} - ${slot['lokasi']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Status: ${slot['status']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showForm(slot: slot),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapusSlot(slot),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
