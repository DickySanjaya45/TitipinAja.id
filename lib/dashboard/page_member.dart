import 'package:flutter/material.dart';

class PageMember extends StatefulWidget {
  const PageMember({super.key});

  @override
  State<PageMember> createState() => _PageMemberState();
}

class _PageMemberState extends State<PageMember> {
  // LIST DATA MEMBER
  List<Map<String, String>> memberList = [
    {
      "id_member": "MBR001",
      "tanggal_daftar": "01-01-2025",
      "diskon": "10%",
    }
  ];

  // ============================
  //   FUNGSI TAMBAH / EDIT
  // ============================
  void _showMemberForm({Map<String, String>? data, int? index}) {
    final idController = TextEditingController(text: data?['id_member'] ?? "");
    final tanggalController =
        TextEditingController(text: data?['tanggal_daftar'] ?? "");
    final diskonController =
        TextEditingController(text: data?['diskon'] ?? "");

    bool isEdit = data != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isEdit ? "Edit Member" : "Tambah Member",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: "ID Member"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tanggalController,
                decoration: const InputDecoration(labelText: "Tanggal Daftar"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: diskonController,
                decoration: const InputDecoration(labelText: "Diskon"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (idController.text.isEmpty ||
                  tanggalController.text.isEmpty ||
                  diskonController.text.isEmpty) {
                return;
              }

              if (isEdit) {
                // UPDATE DATA
                setState(() {
                  memberList[index!] = {
                    "id_member": idController.text,
                    "tanggal_daftar": tanggalController.text,
                    "diskon": diskonController.text,
                  };
                });
              } else {
                // TAMBAH DATA BARU
                setState(() {
                  memberList.add({
                    "id_member": idController.text,
                    "tanggal_daftar": tanggalController.text,
                    "diskon": diskonController.text,
                  });
                });
              }

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B2B9C),
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? "Simpan" : "Tambah"),
          ),
        ],
      ),
    );
  }

  // ============================
  //      FUNGSI HAPUS
  // ============================
  void _hapusMember(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Member"),
        content: const Text("Yakin ingin menghapus member ini?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                memberList.removeAt(index);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Hapus"),
          )
        ],
      ),
    );
  }

  // ============================
  //             UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Member"),
        backgroundColor: const Color(0xFF5B2B9C),
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMemberForm(),
        backgroundColor: const Color(0xFF5B2B9C),
        icon: const Icon(Icons.add),
        label: const Text("Tambah Member"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: memberList.isEmpty
            ? const Center(
                child: Text(
                  "Belum ada data member.",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
            : ListView.builder(
                itemCount: memberList.length,
                itemBuilder: (context, index) {
                  final member = memberList[index];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.card_membership,
                        color: Color(0xFF5B2B9C),
                        size: 40,
                      ),
                      title: Text(
                        member["id_member"]!,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Tanggal: ${member["tanggal_daftar"]}\nDiskon: ${member["diskon"]}",
                      ),

                      // MENU EDIT & HAPUS
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _showMemberForm(
                              data: member,
                              index: index,
                            ),
                            icon: const Icon(Icons.edit, color: Colors.orange),
                          ),
                          IconButton(
                            onPressed: () => _hapusMember(index),
                            icon:
                                const Icon(Icons.delete, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
