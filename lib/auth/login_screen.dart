import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keuangan_baru/auth/home_screen.dart'; // Pastikan import ini benar

// Widget LoginScreen (StatefulWidget)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// State untuk LoginScreen
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _message = '';
  bool _isLoading = false;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _handleLogin() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Nama pengguna dan kata sandi tidak boleh kosong.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Mencoba masuk...';
    });

    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: username,
        password: password,
      );

      if (response.user != null) {
        setState(() {
          _message = 'Login berhasil! Selamat datang.';
        });
        print('User logged in: ${response.user!.id}');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const HomeScreen()), // Menggunakan HomeScreen
          );
        }
      } else {
        setState(() {
          _message = 'Nama pengguna atau kata sandi salah.';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _message = 'Gagal masuk: ${e.message}';
      });
      print('Login AuthException: ${e.message}');
    } catch (e) {
      setState(() {
        _message = 'Terjadi kesalahan: ${e.toString()}';
      });
      print('Login error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F46E5),
              Color(0xFF8B5CF6),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Login Aplikasi Keuangan',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Pengguna',
                        hintText: 'Masukkan nama pengguna Anda',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi',
                        hintText: 'Masukkan kata sandi Anda',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (_message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _message.contains('berhasil')
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
