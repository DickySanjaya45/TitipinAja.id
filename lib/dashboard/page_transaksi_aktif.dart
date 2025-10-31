import 'package:flutter/material.dart';

class PageTransaksiAktif extends StatelessWidget {
  const PageTransaksiAktif({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> transaksiAktif = [
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
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
            const SizedBox(height: 12),
            const Text(
              "Berikut adalah transaksi parkir motor yang sedang berlangsung.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: transaksiAktif.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada transaksi aktif.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: transaksiAktif.length,
                      itemBuilder: (context, index) {
                        final data = transaksiAktif[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5B2B9C),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.motorcycle,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['motor']!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Slot: ${data['slot']}  |  Masuk: ${data['jam_masuk']}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: data['status'] == 'Aktif'
                                        ? Colors.green[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    data['status']!,
                                    style: TextStyle(
                                      color: data['status'] == 'Aktif'
                                          ? Colors.green[700]
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
