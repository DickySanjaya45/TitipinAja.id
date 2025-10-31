import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class MotorPage extends StatelessWidget {
  const MotorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Data Motor'),
      body: const Center(child: Text('Halaman Data Motor')),
    );
  }
}
