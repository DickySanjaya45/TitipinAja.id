import 'package:flutter/material.dart';

class PageMotorSaya extends StatefulWidget {
  const PageMotorSaya({super.key});

  @override
  State<PageMotorSaya> createState() => _PageMotorSayaState();
}

class _PageMotorSayaState extends State<PageMotorSaya> {
  final List<Map<String, String>> motorList = [
    {"nama": "Honda Vario 125", "plat": "B 1234 XYZ", "tahun": "2021"},
    {"nama": "Yamaha NMAX 155", "plat": "D 5678 ABC", "tahun": "2020"},
    {"nama": "Honda Beat Street", "plat": "F 8821 KLP", "tahun": "2019"},
    {"nama": "Yamaha Aerox", "plat": "E 7712 HJK", "tahun": "2022"},
    {"nama": "Honda PCX 160", "plat": "B 9999 QWE", "tahun": "2023"},
    {"nama": "Suzuki Nex II", "plat": "G 5521 LMN", "tahun": "2018"},
    {"nama": "Yamaha Mio M3", "plat": "D 3344 RTY", "tahun": "2020"},
  ];

  final TextEditingController namaController = TextEditingController();
  final TextEditingController platController = TextEditingController();
  final TextEditingController tahunController = TextEditingController();

  @override
  void dispose() {
    namaController.dispose();
    platController.dispose();
    tahunController.dispose();
    super.dispose();
  }

  void _resetForm() {
    namaController.clear();
    platController.clear();
    tahunController.clear();
  }

  void _formMotor({bool isEdit = false, int? index}) {
    if (isEdit && index != null) {
      final motor = motorList[index];
      namaController.text = motor["nama"]!;
      platController.text = motor["plat"]!;
      tahunController.text = motor["tahun"]!;
    } else {
      _resetForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 25,
          left: 22,
          right: 22,
          bottom: MediaQuery.of(context).viewInsets.bottom + 22,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEdit ? "Edit Motor" : "Tambah Motor",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: "Nama Motor",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: platController,
              decoration: InputDecoration(
                labelText: "Plat Nomor",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tahunController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Tahun Motor",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () {
                if (namaController.text.isEmpty ||
                    platController.text.isEmpty ||
                    tahunController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Semua field harus diisi!"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit
                        ? "Motor berhasil diperbarui"
                        : "Motor berhasil ditambahkan"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B2B9C),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isEdit ? "Simpan Perubahan" : "Tambah Motor",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hapusMotor(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Hapus Motor",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Yakin ingin menghapus '${motorList[index]["nama"]}'?",
          style: const TextStyle(fontSize: 16),
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
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
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
        backgroundColor: const Color(0xFF5B2B9C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: motorList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada motor terdaftar.",
                style: TextStyle(fontSize: 17, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: motorList.length,
              itemBuilder: (context, index) {
                final motor = motorList[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),
                    leading: const Icon(
                      Icons.motorcycle,
                      color: Color(0xFF5B2B9C),
                      size: 40,
                    ),
                    title: Text(
                      motor["nama"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Plat: ${motor['plat']} • Tahun: ${motor['tahun']}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                          onPressed: () => _formMotor(isEdit: true, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _hapusMotor(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _formMotor(),
        backgroundColor: const Color(0xFF5B2B9C),
        child: const Icon(Icons.add),
      ),
    );
  }
}