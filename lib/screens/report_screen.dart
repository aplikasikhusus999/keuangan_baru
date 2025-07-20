import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Halaman untuk melihat Laporan Keuangan.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
