import 'package:flutter/material.dart';

class ProfilScreen extends StatelessWidget {
  final String username; // Menyimpan username yang diterima dari konstruktor

  // Konstruktor untuk menerima parameter username
  const ProfilScreen({required this.username, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', 
        style: TextStyle(
          fontSize: 24, 
          color: Colors.white,
        ),
         ), 
        centerTitle: true, 
        backgroundColor: Color.fromARGB(255, 255, 90, 145), 
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
