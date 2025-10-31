import 'package:flutter/material.dart';

class PageMember extends StatefulWidget {
  const PageMember({super.key});

  @override
  State<PageMember> createState() => _PageMemberState();
}

class _PageMemberState extends State<PageMember> {
  Map<String, String>? memberData = {
    "id_member": "MBR001",
    "tanggal_daftar": "01-01-2025",
    "diskon": "10%"
  };

  void _hapusMember() {
    setState(() {
      memberData = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data member berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: memberData == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.info_outline,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        "Belum ada data member.",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.card_membership,
                          size: 100, color: Colors.blueAccent),
                      const SizedBox(height: 20),
                      Text('ID Member: ${memberData!['id_member']}'),
                      Text('Tanggal Daftar: ${memberData!['tanggal_daftar']}'),
                      Text('Diskon: ${memberData!['diskon']}'),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _hapusMember,
                        icon: const Icon(Icons.delete),
                        label: const Text("Hapus Member"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
