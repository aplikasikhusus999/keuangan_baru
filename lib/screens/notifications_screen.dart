import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  // Placeholder data untuk demo UI notifikasi
  final List<Map<String, dynamic>> unreadTransactions = const [
    {
      'id': 1,
      'description': 'Transaksi Penjualan Baru #123',
      'amount': 150000.00,
      'date': '2024-07-21 10:30',
      'isRead': false
    },
    {
      'id': 2,
      'description': 'Pembelian Bahan Baku #456',
      'amount': 750000.00,
      'date': '2024-07-21 09:15',
      'isRead': false
    },
    {
      'id': 3,
      'description': 'Gaji Karyawan Dibayarkan',
      'amount': 2000000.00,
      'date': '2024-07-20 17:00',
      'isRead': false
    },
  ];

  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Transaksi'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: unreadTransactions.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada notifikasi baru.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: unreadTransactions.length,
              itemBuilder: (context, index) {
                final transaction = unreadTransactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      transaction['amount'] > 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color:
                          transaction['amount'] > 0 ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      transaction['description'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${transaction['date']} - Rp ${transaction['amount'].toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    ),
                    onTap: () {
                      // TODO: Logika untuk menandai transaksi sebagai sudah dibaca
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Melihat detail transaksi ${transaction['id']}')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
