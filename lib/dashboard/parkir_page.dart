import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class ParkirPage extends StatelessWidget {
  const ParkirPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Slot Parkir'),
      body: const Center(child: Text('Halaman Slot Parkir')),
    );
  }
}
