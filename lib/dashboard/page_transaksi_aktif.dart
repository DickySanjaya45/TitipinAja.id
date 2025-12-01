import 'package:flutter/material.dart';

class PageTransaksiAktif extends StatefulWidget {
  const PageTransaksiAktif({super.key});

  @override
  State<PageTransaksiAktif> createState() => _PageTransaksiAktifState();
}

class _PageTransaksiAktifState extends State<PageTransaksiAktif> {
  List<Map<String, String>> transaksi = [
    {
      "motor": "Honda Vario",
      "slot": "A12",
      "jam_masuk": "09:00",
      "status": "Aktif",
    },
    {
      "motor": "Yamaha NMAX",
      "slot": "B07",
      "jam_masuk": "10:15",
      "status": "Aktif",
    },
  ];

  final motorController = TextEditingController();
  final slotController = TextEditingController();
  final jamController = TextEditingController();

  void _clearForm() {
    motorController.clear();
    slotController.clear();
    jamController.clear();
  }

  // ---------------------------
  // FORM TAMBAH & EDIT
  // ---------------------------
  void _showForm({bool edit = false, int? index}) {
    if (edit && index != null) {
      motorController.text = transaksi[index]["motor"]!;
      slotController.text = transaksi[index]["slot"]!;
      jamController.text = transaksi[index]["jam_masuk"]!;
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          edit ? "Edit Transaksi" : "Tambah Transaksi",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInput("Nama Motor", motorController),
            const SizedBox(height: 12),
            _buildInput("Slot Parkir", slotController),
            const SizedBox(height: 12),
            _buildInput("Jam Masuk (ex: 09:00)", jamController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B2B9C)),
            onPressed: () {
              if (motorController.text.isEmpty ||
                  slotController.text.isEmpty ||
                  jamController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Semua field harus diisi!")),
                );
                return;
              }

              setState(() {
                if (edit && index != null) {
                  transaksi[index] = {
                    "motor": motorController.text,
                    "slot": slotController.text,
                    "jam_masuk": jamController.text,
                    "status": "Aktif",
                  };
                } else {
                  transaksi.add({
                    "motor": motorController.text,
                    "slot": slotController.text,
                    "jam_masuk": jamController.text,
                    "status": "Aktif",
                  });
                }
              });

              Navigator.pop(context);
              _clearForm();
            },
            child: Text(edit ? "Simpan" : "Tambah"),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // DIALOG HAPUS
  // ---------------------------
  void _hapus(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Transaksi"),
        content: const Text("Yakin ingin menghapus transaksi ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              setState(() => transaksi.removeAt(index));
              Navigator.pop(context);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // INPUT FIELD BUILDER
  // ---------------------------
  Widget _buildInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
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

  // ---------------------------
  // UI PAGE
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        title: const Text("Transaksi Aktif"),
        backgroundColor: const Color(0xFF5B2B9C),
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5B2B9C),
        onPressed: () => _showForm(edit: false),
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daftar Transaksi Aktif",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B2B9C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Berikut adalah transaksi parkir motor yang sedang berlangsung.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: transaksi.isEmpty
                  ? const Center(
                      child: Text("Belum ada transaksi aktif.",
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      itemCount: transaksi.length,
                      itemBuilder: (context, index) {
                        final data = transaksi[index];

                        return Card(
                          elevation: 1,
                          shadowColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(18),
                            leading: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B2B9C),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.motorcycle,
                                  color: Colors.white),
                            ),
                            title: Text(
                              data["motor"]!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Slot: ${data['slot']}  |  Masuk: ${data['jam_masuk']}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                if (value == "edit") {
                                  _showForm(edit: true, index: index);
                                } else if (value == "hapus") {
                                  _hapus(index);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: "edit",
                                  child: Text("Edit"),
                                ),
                                const PopupMenuItem(
                                  value: "hapus",
                                  child: Text("Hapus"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
