import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keuangan_baru/auth/login_screen.dart'; // Pastikan import ini benar

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zdcbxvakofohcfcarbjp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpkY2J4dmFrb2ZvaGNmY2FyYmpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI5MzkyMzIsImV4cCI6MjA2ODUxNTIzMn0.beS9qDfIVqFaG47GcyqdAii2up3OvA5WRe5ZLfhsxUs',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Keuangan',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: const LoginScreen(),
    );
  }
}
