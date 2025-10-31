import 'package:flutter/material.dart';

class PageMember extends StatelessWidget {
  const PageMember({super.key});

  @override
  Widget build(BuildContext context) {
    final memberData = {
      "id_member": "MBR001",
      "tanggal_daftar": "01-01-2025",
      "diskon": "10%"
    };

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.card_membership, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text('ID Member: ${memberData['id_member']}'),
              Text('Tanggal Daftar: ${memberData['tanggal_daftar']}'),
              Text('Diskon: ${memberData['diskon']}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text('Perbarui Keanggotaan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
