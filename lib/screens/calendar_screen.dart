import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
        backgroundColor: Colors.purple.shade400,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Halaman untuk Kalender atau Jadwal.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
