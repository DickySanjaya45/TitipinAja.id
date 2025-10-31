import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/dashboard_tile.dart';


class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard Admin'),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: const [
            DashboardTile(icon: Icons.people, title: 'Data Pengguna'),
            DashboardTile(icon: Icons.motorcycle, title: 'Data Motor'),
            DashboardTile(icon: Icons.payment, title: 'Pembayaran'),
            DashboardTile(icon: Icons.history, title: 'Riwayat Transaksi'),
            DashboardTile(icon: Icons.local_parking, title: 'Slot Parkir'),
            DashboardTile(icon: Icons.settings, title: 'Pengaturan'),
          ],
        ),
      ),
    );
  }
}
