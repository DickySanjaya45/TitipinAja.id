import 'package:flutter/material.dart';

class PagePembayaran extends StatefulWidget {
  const PagePembayaran({super.key});

  @override
  State<PagePembayaran> createState() => _PagePembayaranState();
}

class _PagePembayaranState extends State<PagePembayaran> {
  final List<Map<String, String>> pembayaranList = [
    {
      "motor": "Honda Vario",
      "jumlah": "Rp 10.000",
      "metode": "Tunai",
      "tanggal": "31-10-2025"
    },
  ];

  final motorController = TextEditingController();
  final jumlahController = TextEditingController();
  final metodeController = TextEditingController();

  @override
  void dispose() {
    motorController.dispose();
    jumlahController.dispose();
    metodeController.dispose();
    super.dispose();
  }

  void _clearInput() {
    motorController.clear();
    jumlahController.clear();
    metodeController.clear();
  }

  // 🔵 Form Tambah/Edit
  void _showPembayaranForm({Map<String, String>? data, int? index}) {
    final isEdit = data != null;

    motorController.text = data?['motor'] ?? '';
    jumlahController.text = data?['jumlah'] ?? '';
    metodeController.text = data?['metode'] ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isEdit ? "Edit Pembayaran" : "Tambah Pembayaran",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _inputField("Motor", motorController),
            const SizedBox(height: 12),
            _inputField("Jumlah (Rp)", jumlahController,
                type: TextInputType.number),
            const SizedBox(height: 12),
            _inputField("Metode Pembayaran", metodeController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearInput();
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B2B9C),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (motorController.text.isEmpty ||
                  jumlahController.text.isEmpty ||
                  metodeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Semua field harus diisi!"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              setState(() {
                if (isEdit) {
                  pembayaranList[index!] = {
                    "motor": motorController.text,
                    "jumlah": jumlahController.text,
                    "metode": metodeController.text,
                    "tanggal": data['tanggal'] ?? "",
                  };
                } else {
                  pembayaranList.add({
                    "motor": motorController.text,
                    "jumlah": jumlahController.text,
                    "metode": metodeController.text,
                    "tanggal": DateTime.now().toString().split(' ')[0],
                  });
                }
              });

              Navigator.pop(context);
              _clearInput();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit
                      ? "Data pembayaran berhasil diperbarui"
                      : "Pembayaran berhasil ditambahkan"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(isEdit ? "Update" : "Simpan"),
          ),
        ],
      ),
    );
  }

  // 🔴 Hapus
  void _hapusPembayaran(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Pembayaran"),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                pembayaranList.removeAt(index);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Data berhasil dihapus"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // Widget helper
  Widget _inputField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Pembayaran"),
        backgroundColor: const Color(0xFF5B2B9C),
        foregroundColor: Colors.white,
      ),
      body: pembayaranList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada data pembayaran",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pembayaranList.length,
              itemBuilder: (context, index) {
                final bayar = pembayaranList[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B2B9C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.payment,
                          color: Colors.white, size: 28),
                    ),
                    title: Text(
                      bayar['motor']!,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Jumlah: ${bayar['jumlah']}\nMetode: ${bayar['metode']}",
                        style:
                            const TextStyle(height: 1.4, color: Colors.black87),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bayar['tanggal']!,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showPembayaranForm(
                                  data: bayar, index: index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusPembayaran(index),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5B2B9C),
        child: const Icon(Icons.add),
        onPressed: () => _showPembayaranForm(),
      ),
    );
  }
}
