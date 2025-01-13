import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'home.dart'; // Import halaman home

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Supabase.initialize(
    url: 'https://xmgzyqgsubdfvsufiukb.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhtZ3p5cWdzdWJkZnZzdWZpdWtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzU1MDUsImV4cCI6MjA1MTcxMTUwNX0.qM7BgJOOvT15pNEbYL3WyjqR8uvLgo9pRrvxUOZ84KM',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Rute awal
      routes: {
        '/': (context) => LoginScreen(), // Rute login
        '/home': (context) => HomeScreen(username: ''), // Rute home
      },
    );
  }
}
