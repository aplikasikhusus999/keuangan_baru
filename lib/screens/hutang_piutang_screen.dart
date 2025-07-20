import 'package:flutter/material.dart';

class HutangPiutangScreen extends StatelessWidget {
  const HutangPiutangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hutang & Piutang'),
        backgroundColor: Colors.brown.shade400,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Halaman untuk mengelola Hutang dan Piutang.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
