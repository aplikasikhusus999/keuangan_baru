import 'package:flutter/material.dart';

class OtherMenuScreen extends StatelessWidget {
  const OtherMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Lainnya'),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Halaman untuk menu-menu tambahan.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
