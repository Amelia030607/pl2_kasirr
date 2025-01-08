import 'package:flutter/material.dart';  // Mengimpor pustaka Flutter untuk membangun UI aplikasi.
import 'login.dart'; // Mengimpor halaman LoginScreen untuk navigasi ke halaman login

class HomeScreen extends StatelessWidget {  // Mendeklarasikan HomeScreen sebagai widget stateless.
  // Data tentang kue yang akan ditampilkan dalam bentuk list
  final List<Map<String, String>> cakeData = [
    {'name': 'Chocolate Cake', 'price': '50.000'},
    {'name': 'Vanilla Cake', 'price': '45.000'},
    {'name': 'Strawberry Cake', 'price': '55.000'},
    {'name': 'Red Velvet Cake', 'price': '65.000'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Membuat struktur da sar halaman (Scaffold) untuk halaman home
      appBar: AppBar(  // Membuat app bar dengan judul dan tombol logout
        title: const Text("Kasir Penjualan Cake"),  // Judul app bar
        backgroundColor: Color(0xFF8993C9),  // Warna app bar
        centerTitle: true,
        actions: [
          IconButton(  // Tombol logout di bagian actions app bar
            icon: const Icon(Icons.logout),  // Ikon logout
            onPressed: () {  // Ketika tombol logout ditekan
              // Navigasi kembali ke halaman login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),  // Menavigasi ke LoginScreen
              );
            },
          ),
        ],
      ),
      body: Container(  // Kontainer utama untuk tubuh halaman
        padding: const EdgeInsets.all(20),  // Memberikan padding sekitar kontainer
        decoration: const BoxDecoration(  // Desain latar belakang dengan gradasi warna
          gradient: LinearGradient(
            colors: [Color(0xFFB0C4F5), Color(0xFF8993C9)],  // Warna gradasi latar belakang
            begin: Alignment.topLeft,  // Titik awal gradasi di pojok kiri atas
            end: Alignment.bottomRight,  // Titik akhir gradasi di pojok kanan bawah
          ),
        ),
        child: ListView.builder(  // Membuat list yang dapat digulir
          itemCount: cakeData.length,  // Jumlah item berdasarkan panjang list cakeData
          itemBuilder: (context, index) {  // Fungsi untuk membangun setiap item di dalam list
            return Card(  // Membungkus setiap item dalam card untuk tampilan yang lebih menarik
              margin: const EdgeInsets.symmetric(vertical: 10),  // Memberikan jarak vertikal antar card
              shape: RoundedRectangleBorder(  // Membuat sudut card menjadi melengkung
                borderRadius: BorderRadius.circular(15),  // Mengatur radius sudut
              ),
              elevation: 5,  // Memberikan efek bayangan pada card
              child: ListTile(  // Membuat tile dalam card untuk setiap item
                title: Text(cakeData[index]['name'] ?? ''),  // Menampilkan nama kue
                subtitle: Text('Price: ${cakeData[index]['price']}'),  // Menampilkan harga kue
                leading: const Icon(Icons.cake, color: Color(0xFF8993C9)),  // Ikon kue di sebelah kiri
                onTap: () {  // Fungsi yang dijalankan saat item dipilih
                  ScaffoldMessenger.of(context).showSnackBar(  // Menampilkan SnackBar dengan pesan
                    SnackBar(
                      content: Text('You tapped on ${cakeData[index]['name']}'),  // Pesan yang ditampilkan
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
