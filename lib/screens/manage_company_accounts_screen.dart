import 'package:flutter/material.dart';

class ManageCompanyAccountsScreen extends StatelessWidget {
  const ManageCompanyAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Perusahaan & Akun'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Di sini Anda dapat mengedit nama perusahaan dan menambah/mengelola akun keuangan.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Logika untuk mengedit nama perusahaan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Edit Nama Perusahaan')),
                );
              },
              child: const Text('Edit Nama Perusahaan'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Logika untuk menambah akun keuangan baru
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Tambah Akun Keuangan')),
                );
              },
              child: const Text('Tambah Akun Keuangan'),
            ),
          ],
        ),
      ),
    );
  }
}
