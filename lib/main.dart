import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart'; // Import halaman login

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding Flutter sudah terinisialisasi
  await Supabase.initialize(
    url: 'https://xmgzyqgsubdfvsufiukb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhtZ3p5cWdzdWJkZnZzdWZpdWtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzU1MDUsImV4cCI6MjA1MTcxMTUwNX0.qM7BgJOOvT15pNEbYL3WyjqR8uvLgo9pRrvxUOZ84KM',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // Panggil halaman login
    );
  }
}
