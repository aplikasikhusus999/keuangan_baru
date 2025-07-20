import 'package:flutter/material.dart';

class LatestTransactionsList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const LatestTransactionsList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            leading: Icon(
              transaction['type'] == 'credit'
                  ? Icons.arrow_circle_up
                  : Icons.arrow_circle_down,
              color:
                  transaction['type'] == 'credit' ? Colors.green : Colors.red,
            ),
            title: Text(transaction['description']),
            subtitle: Text(transaction['date']),
            trailing: Text(
              'Rp ${transaction['amount'].toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
              style: TextStyle(
                color:
                    transaction['type'] == 'credit' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
