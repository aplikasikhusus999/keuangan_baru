import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keuangan_baru/auth/login_screen.dart'; // Import LoginScreen untuk navigasi logout
import 'package:keuangan_baru/widgets/custom_app_bar.dart'; // Import CustomAppBar
import 'package:keuangan_baru/widgets/saldo_card.dart'; // Import SaldoCard
import 'package:keuangan_baru/widgets/menu_grid_item.dart'; // Import MenuGridItem
import 'package:keuangan_baru/widgets/latest_transactions_list.dart'; // Import LatestTransactionsList

// Import screens untuk navigasi BottomNavigationBar dan Grid
import 'package:keuangan_baru/screens/calendar_screen.dart';
import 'package:keuangan_baru/screens/hutang_piutang_screen.dart';
import 'package:keuangan_baru/screens/debit_screen.dart';
import 'package:keuangan_baru/screens/credit_screen.dart';
import 'package:keuangan_baru/screens/report_screen.dart';
import 'package:keuangan_baru/screens/other_menu_screen.dart';
import 'package:keuangan_baru/screens/manage_company_accounts_screen.dart'; // Import layar baru
import 'package:keuangan_baru/screens/notifications_screen.dart'; // Import layar notifikasi baru
import 'dart:async'; // Import for StreamSubscription

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  int _selectedIndex = 0; // Untuk BottomNavigationBar

  // Placeholder data for UI demonstration
  final String _accountName = 'Perusahaan 1'; // Default nama perusahaan
  int _unreadNotifications = 0; // Jumlah transaksi belum dibuka (dinamis)

  // Daftar halaman untuk BottomNavigationBar
  final List<Widget> _pages = [
    // Halaman Home (konten utama HomeScreen ini)
    _HomeScreenContent(), // Menggunakan widget terpisah untuk konten home
    const CalendarScreen(),
    const HutangPiutangScreen(),
  ];

  // Stream subscription untuk notifikasi
  StreamSubscription<List<Map<String, dynamic>>>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _listenForNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // Fungsi untuk mendengarkan notifikasi (transaksi baru)
  void _listenForNotifications() {
    // Mendengarkan semua insert ke tabel transactions
    _notificationSubscription = supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .order('created_at',
            ascending: false) // Urutkan berdasarkan waktu pembuatan terbaru
        .listen(
          (List<Map<String, dynamic>> data) {
            // Logika untuk menghitung notifikasi yang belum dibaca.
            // Jika Anda memiliki kolom `is_read` atau `read_by` di transaksi,
            // Anda akan menghitung berdasarkan itu.
            // Untuk demo awal, kita akan menghitung semua transaksi sebagai "notifikasi"
            // dan menampilkan SnackBar untuk setiap transaksi baru.

            if (data.isNotEmpty) {
              // Perbarui badge notifikasi dengan jumlah total transaksi (atau yang belum dibaca)
              setState(() {
                _unreadNotifications =
                    data.length; // Contoh: hitung semua sebagai notifikasi
              });

              // Tampilkan SnackBar untuk transaksi baru (jika ada yang baru masuk)
              // Ini adalah contoh sederhana, Anda mungkin perlu logika yang lebih canggih
              // untuk mendeteksi hanya transaksi yang baru diinsert sejak terakhir kali dilihat.
              // Untuk saat ini, kita akan menampilkan notif untuk setiap perubahan stream.
              if (mounted) {
                final latestTransaction = data.first;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Transaksi baru: ${latestTransaction['description']} (Rp ${latestTransaction['amount']})'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            } else {
              setState(() {
                _unreadNotifications = 0;
              });
            }
          },
          onError: (error) {
            print('Error listening for notifications: $error');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Gagal memuat notifikasi realtime: $error')),
              );
            }
          },
        );

    // Ambil jumlah notifikasi awal
    _fetchInitialNotificationsCount();
  }

  Future<void> _fetchInitialNotificationsCount() async {
    try {
      // Ambil jumlah total transaksi sebagai notifikasi awal
      final response = await supabase.from('transactions').select('id').count(
          CountOption.exact); // Gunakan .count() untuk mendapatkan jumlah

      setState(() {
        _unreadNotifications = response.count;
      });
    } on PostgrestException catch (e) {
      print('Error fetching initial notification count: ${e.message}');
    } catch (e) {
      print('Error fetching initial notification count: $e');
    }
  }

  // Fungsi untuk menangani logout
  Future<void> _logout() async {
    try {
      await supabase.auth.signOut();
      // Setelah logout, arahkan kembali ke layar login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: ${e.toString()}')),
        );
      }
      print('Logout error: $e');
    }
  }

  // Fungsi untuk menangani pemilihan tab navigasi
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk menangani tap pada informasi akun/perusahaan di AppBar
  void _onAccountInfoTapped() {
    // Navigasi ke layar ManageCompanyAccountsScreen
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const ManageCompanyAccountsScreen()),
    );
  }

  // Fungsi untuk menangani tap pada ikon notifikasi di AppBar
  void _onNotificationsTapped() {
    // Navigasi ke layar NotificationsScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
    // TODO: Setelah notifikasi dibuka, set _unreadNotifications menjadi 0 atau kurangi jumlahnya
    setState(() {
      _unreadNotifications = 0; // Reset badge saat halaman notifikasi dibuka
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan sesi pengguna saat ini untuk menampilkan email pengguna
    final User? user = supabase.auth.currentUser;
    final String userEmail =
        user?.email ?? 'Pengguna Tidak Dikenal'; // Default jika email null

    return Scaffold(
      appBar: CustomAppBar(
        accountName: _accountName,
        userEmail: userEmail, // Meneruskan email pengguna yang login
        unreadNotifications: _unreadNotifications,
        onLogout: _logout,
        onAccountInfoTap: _onAccountInfoTapped, // Menggunakan fungsi baru
        onNotificationsTap: _onNotificationsTapped, // Menggunakan fungsi baru
      ),
      body:
          _pages[_selectedIndex], // Menampilkan halaman sesuai tab yang dipilih
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Hutang-Piutang', // Label diperbarui
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Fitur Tambah Transaksi akan datang!')),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Transaksi',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Konten utama HomeScreen yang dipisahkan menjadi widget tersendiri
class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent({super.key});

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final SupabaseClient supabase = Supabase.instance.client;

  double _currentBalance = 0.0;
  double _totalDebit = 0.0;
  double _totalCredit = 0.0;
  List<Map<String, dynamic>> _latestTransactions = [];
  StreamSubscription<List<Map<String, dynamic>>>? _transactionsStream;
  StreamSubscription<List<Map<String, dynamic>>>?
      _summaryStream; // Stream baru untuk summary

  @override
  void initState() {
    super.initState();
    _fetchTransactionsAndListen();
    _fetchAndCalculateFinancialSummary(); // Panggil secara terpisah
  }

  @override
  void dispose() {
    _transactionsStream
        ?.cancel(); // Pastikan stream ditutup saat widget di-dispose
    _summaryStream?.cancel(); // Batalkan stream summary juga
    super.dispose();
  }

  Future<void> _fetchTransactionsAndListen() async {
    // Mendapatkan stream untuk 5 transaksi terakhir secara realtime
    _transactionsStream = supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(5)
        .listen(
          (List<Map<String, dynamic>> data) {
            setState(() {
              _latestTransactions = data
                  .map((item) => {
                        'id': item['id'],
                        'description': item['description'],
                        'amount': (item['amount'] as num).toDouble(),
                        'type': item['type'],
                        'date': item['transaction_date']
                            .toString()
                            .substring(0, 10), // Ambil hanya tanggal
                        'time': item['transaction_date']
                            .toString()
                            .substring(11, 16), // Ambil hanya waktu (HH:mm)
                        // 'proof_url': item['proof_url'], // Jika ada kolom bukti
                      })
                  .toList();
            });
            print('Latest transactions updated: $_latestTransactions');
          },
          onError: (error) {
            print('Error listening to latest transactions: $error');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Gagal memuat transaksi terbaru: $error')),
              );
            }
          },
        );
  }

  Future<void> _fetchAndCalculateFinancialSummary() async {
    // Mendengarkan semua transaksi untuk perhitungan saldo secara realtime
    _summaryStream = supabase
        .from('transactions')
        .stream(primaryKey: ['id']) // Gunakan primaryKey untuk efisiensi stream
        .listen(
      (List<Map<String, dynamic>> allTransactions) {
        _calculateFinancialSummary(allTransactions);
      },
      onError: (error) {
        print('Error listening to all transactions for summary: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Gagal memuat ringkasan keuangan realtime: $error')),
          );
        }
      },
    );
  }

  void _calculateFinancialSummary(List<Map<String, dynamic>> transactions) {
    double tempDebit = 0.0;
    double tempCredit = 0.0;

    for (var transaction in transactions) {
      // Pastikan amount adalah numeric dan type adalah string
      final double amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
      final String type = (transaction['type'] as String?) ?? '';

      if (type == 'debit') {
        tempDebit += amount;
      } else if (type == 'credit') {
        tempCredit += amount;
      }
    }

    setState(() {
      _totalDebit = tempDebit;
      _totalCredit = tempCredit;
      _currentBalance = tempCredit - tempDebit; // Saldo = Kredit - Debit
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4F46E5), // Indigo-600
            Color(0xFF8B5CF6), // Purple-800
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menggunakan SaldoCard yang baru dengan data dinamis
              SaldoCard(
                currentBalance: _currentBalance,
                totalDebit: _totalDebit,
                totalCredit: _totalCredit,
              ),
              const SizedBox(height: 20),

              // Grid Menu
              Text(
                'Menu Cepat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  MenuGridItem(
                    icon: Icons.arrow_downward,
                    title: 'Debit',
                    color: Colors.red.shade400,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DebitScreen()));
                    },
                  ),
                  MenuGridItem(
                    icon: Icons.arrow_upward,
                    title: 'Kredit',
                    color: Colors.green.shade400,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreditScreen()));
                    },
                  ),
                  MenuGridItem(
                    icon: Icons.description,
                    title: 'Laporan',
                    color: Colors.blue.shade400,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ReportScreen()));
                    },
                  ),
                  MenuGridItem(
                    icon: Icons.more_horiz,
                    title: 'Lainnya',
                    color: Colors.orange.shade400,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OtherMenuScreen()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5 Transaksi Terakhir
              Text(
                '5 Transaksi Terakhir',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              LatestTransactionsList(
                  transactions:
                      _latestTransactions), // Menggunakan LatestTransactionsList
            ],
          ),
        ),
      ),
    );
  }
}
