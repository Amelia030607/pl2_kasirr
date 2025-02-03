import 'package:flutter/material.dart';

class ProfilScreen extends StatelessWidget {
  final String username; // Menyimpan username yang diterima dari konstruktor

  // Konstruktor untuk menerima parameter username
  const ProfilScreen({required this.username, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min, // Menyesuaikan ukuran kolom
          children: [
            Icon(Icons.person, color: Colors.white), // Menambahkan ikon person
            const SizedBox(width: 8), // Jarak antara ikon dan teks
            const Text(
              'PROFIL',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 90, 145), // Warna latar belakang AppBar
      ),

      body: Container(
        color: Colors.pink[50], 
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Menyusun widget di tengah secara vertikal
            children: [
              const Text(
                'Halo,', 
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                ),
              ),
              Text(
                username, // Menampilkan username yang diterima sebagai parameter
                style: const TextStyle(
                  fontSize: 24, 
                  color: Colors.pinkAccent, 
                ),
              ),
              const SizedBox(height: 20), 
              const Text(
                'Selamat datang di aplikasi Kasir Cake Shop!', 
                textAlign: TextAlign.center, 
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
