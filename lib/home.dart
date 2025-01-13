import 'package:flutter/material.dart';
import 'login.dart'; // Mengimpor halaman LoginScreen untuk navigasi ke halaman login

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold adalah struktur dasar halaman aplikasi Flutter.
      appBar: AppBar(
        backgroundColor: Colors.white, // Warna latar belakang AppBar
        elevation: 0, // Menghilangkan bayangan pada AppBar
        title: const Text(
          "Cake Shop", // Judul yang ditampilkan di AppBar
          style: TextStyle(
            color: Colors.pink, // Warna teks pada AppBar
            fontSize: 20, // Ukuran font teks
            fontWeight: FontWeight.bold, // Gaya font bold
          ),
        ),
        actions: [
          // Bagian untuk menambahkan ikon dan tombol di sisi kanan AppBar
          
          // Ikon Home dengan tulisan "Home"
          IconButton(
            icon: const Icon(Icons.home, color: Colors.pink), // Ikon rumah
            onPressed: () {}, // Fungsi yang akan dijalankan saat ikon ditekan (kosong)
            tooltip: "Home", // Tooltip yang muncul ketika ikon di-hover atau diketuk
          ),
          
          // Ikon Keranjang dengan tulisan "Data Produk"
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.pink), // Ikon keranjang
            onPressed: () {}, // Fungsi yang akan dijalankan saat ikon ditekan (kosong)
            tooltip: "Data Produk", // Tooltip yang muncul ketika ikon di-hover atau diketuk
          ),
          
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.pink), // Ikon logout
            onPressed: () {
              // Menampilkan dialog konfirmasi logout ketika ikon logout ditekan
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"), // Judul dialog
                    content: const Text("Apakah Anda yakin ingin melogout?"), // Pesan dalam dialog
                    actions: <Widget>[
                      // Tombol-tombol dalam dialog
                      TextButton(
                        onPressed: () {
                          // Menutup dialog jika pengguna memilih Batal
                          Navigator.of(context).pop();
                        },
                        child: const Text("Batal"), // Teks pada tombol Batal
                      ),
                      TextButton(
                        onPressed: () {
                          // Menavigasi pengguna ke halaman login jika memilih Ya
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text("Ya"), // Teks pada tombol Ya
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: "Logout",
          ),
        ],
      ),
      
      body: Container(
        color: const Color(0xFFFFF5F7), // Warna latar belakang halaman
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Memberikan padding di sekeliling body
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Dua kolom per baris
              crossAxisSpacing: 30, // Jarak horizontal antar kolom
              mainAxisSpacing: 20, // Jarak vertikal antar baris
            ),
            itemCount: 8, // Jumlah item yang ditampilkan dalam grid
            itemBuilder: (context, index) {
              // Membangun item dalam grid
              return Container(
                width: 60, // Lebar Container yang lebih kecil
                height: 60, // Tinggi Container yang lebih kecil
                decoration: BoxDecoration(
                  color: Colors.white, // Warna latar belakang setiap kartu
                  borderRadius: BorderRadius.circular(16), // Sudut kartu melengkung
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Warna bayangan kartu
                      blurRadius: 10, // Efek blur pada bayangan
                      offset: const Offset(0, 4), // Posisi bayangan
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Menyusun widget secara vertikal di tengah
                  children: [
                    const Icon(
                      Icons.cake, // Ikon kue
                      color: Colors.pink, // Warna ikon
                      size: 20, // Ukuran ikon
                    ),
                    const SizedBox(height: 4), // Jarak vertikal yang lebih kecil antar ikon dan teks
                    const Text(
                      "Red Velvet Cake", // Placeholder nama kue
                      style: TextStyle(
                        fontSize: 16, // Ukuran teks
                        fontWeight: FontWeight.bold, // Gaya teks bold
                        color: Colors.black54, // Warna teks
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
