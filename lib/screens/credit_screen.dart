import 'package:flutter/material.dart';

class CreditScreen extends StatelessWidget {
  const CreditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Kredit'),
        backgroundColor: Colors.green.shade400,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Halaman untuk mengelola Kredit.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
