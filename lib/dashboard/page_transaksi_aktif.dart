import 'package:flutter/material.dart';

class PageTransaksiAktif extends StatefulWidget {
  const PageTransaksiAktif({super.key});

  @override
  State<PageTransaksiAktif> createState() => _PageTransaksiAktifState();
}

class _PageTransaksiAktifState extends State<PageTransaksiAktif> {
  // Data dummy
  List<Map<String, dynamic>> transaksi = [
    {"motor": "Honda Vario", "slot": "A12", "jam_masuk": "09:00", "status": "Aktif", "biaya": 2000},
    {"motor": "Yamaha NMAX", "slot": "B07", "jam_masuk": "10:15", "status": "Aktif", "biaya": 4000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Transaksi Aktif"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: transaksi.length,
        itemBuilder: (context, index) {
          final data = transaksi[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon Status
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7FA),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.timer, color: Color(0xFF00ACC1)),
                  ),
                  const SizedBox(width: 16),
                  
                  // Info Utama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['motor'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.local_parking, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text("Slot ${data['slot']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(width: 10),
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(data['jam_masuk'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Chip
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Aktif",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Rp ${data['biaya']}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
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
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}