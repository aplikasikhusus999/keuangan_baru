import 'package:flutter/material.dart';
import 'package:keuangan_baru/models/add_debit.dart'; // Import AddDebitScreen
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'dart:async'; // Import for StreamSubscription

class DebitScreen extends StatefulWidget {
  const DebitScreen({super.key});

  @override
  State<DebitScreen> createState() => _DebitScreenState();
}

class _DebitScreenState extends State<DebitScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  double _totalDebit = 0.0; // Ini akan dihitung dari Supabase
  String _selectedPeriod = 'Harian'; // Filter waktu yang dipilih

  // Daftar transaksi debit yang akan diisi dari Supabase secara realtime
  List<Map<String, dynamic>> _debitTransactions = [];

  // FIX: Mengubah tipe dari Stream? menjadi StreamSubscription?
  StreamSubscription<List<Map<String, dynamic>>>?
      _debitTransactionsStreamSubscription;

  @override
  void initState() {
    super.initState();
    _listenToDebitTransactions();
  }

  @override
  void dispose() {
    // Membatalkan subscription saat widget di-dispose
    _debitTransactionsStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _listenToDebitTransactions() async {
    // Mendengarkan semua transaksi debit dari Supabase secara realtime
    _debitTransactionsStreamSubscription = supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('type', 'debit') // Hanya ambil transaksi dengan type 'debit'
        .order('transaction_date',
            ascending: false) // Urutkan berdasarkan tanggal terbaru
        .listen(
          (List<Map<String, dynamic>> data) {
            setState(() {
              _debitTransactions = data
                  .map((item) => {
                        'id': item['id'],
                        'description': item['description'],
                        'amount': (item['amount'] as num).toDouble(),
                        'date': item['transaction_date']
                            .toString()
                            .substring(0, 10), // Ambil hanya tanggal
                        'time': item['transaction_date']
                            .toString()
                            .substring(11, 16), // Ambil hanya waktu (HH:mm)
                        // 'proof_url': item['proof_url'], // Tambahkan jika ada kolom bukti
                      })
                  .toList();
              _calculateTotalDebit(); // Hitung ulang total debit
            });
          },
          onError: (error) {
            print('Error listening to debit transactions: $error');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memuat transaksi debit: $error')),
              );
            }
          },
        );
  }

  void _calculateTotalDebit() {
    double tempDebit = 0.0;
    for (var transaction in _debitTransactions) {
      tempDebit += (transaction['amount'] as double);
    }
    setState(() {
      _totalDebit = tempDebit;
    });
  }

  void _editTransaction(String id) {
    // TODO: Logika untuk mengedit transaksi berdasarkan ID
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mengedit transaksi dengan ID: $id')),
    );
  }

  Future<void> _deleteTransaction(String id) async {
    // Logika untuk menghapus transaksi dari Supabase
    try {
      await supabase.from('transactions').delete().eq('id', id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi debit berhasil dihapus!')),
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus debit: ${e.message}')),
        );
      }
      print('Supabase error: ${e.message}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Debit'),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Bagian Jumlah Debit
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color:
                Colors.red.shade50, // Latar belakang ringan untuk bagian debit
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jumlah Debit Saat Ini',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${(_totalDebit).toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          // Bar Navigasi Harian, Mingguan, Bulanan, Tahunan
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterButton('Harian'),
                _buildFilterButton('Mingguan'),
                _buildFilterButton('Bulanan'),
                _buildFilterButton('Tahunan'),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          // Daftar Transaksi Debit
          Expanded(
            child: _debitTransactions.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada transaksi debit.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _debitTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _debitTransactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            child: const Icon(Icons.arrow_downward,
                                color: Colors.red),
                          ),
                          title: Text(
                            transaction['description'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              '${transaction['date']} - ${transaction['time']}'),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp ${transaction['amount'].toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.image,
                                        size: 20, color: Colors.blue),
                                    onPressed: () {
                                      // TODO: Tampilkan bukti gambar dari URL (transaction['proof_url'])
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Melihat bukti untuk ${transaction['description']}')),
                                      );
                                    },
                                    tooltip: 'Lihat Bukti',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 20, color: Colors.orange),
                                    onPressed: () =>
                                        _editTransaction(transaction['id']),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 20, color: Colors.grey),
                                    onPressed: () =>
                                        _deleteTransaction(transaction['id']),
                                    tooltip: 'Hapus',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigasi ke AddDebitScreen dan tunggu hasilnya
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDebitScreen()),
          );
          // Karena data sudah realtime, tidak perlu _onAddDebitSuccess() lagi.
          // Perubahan akan otomatis terpantau oleh stream.
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Tambah Debit', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFilterButton(String period) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedPeriod = period;
        });
        // TODO: Logika untuk memfilter transaksi berdasarkan periode dari Supabase
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Filter: $period')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedPeriod == period
            ? Colors.red.shade400
            : Colors.grey.shade200,
        foregroundColor:
            _selectedPeriod == period ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: _selectedPeriod == period ? 5 : 1,
      ),
      child: Text(period),
    );
  }
}
