import 'package:flutter/material.dart';
import 'home.dart'; // Pastikan untuk mengimpor HomeScreen, halaman tujuan setelah login

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState(); // Menyediakan status untuk halaman login
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController = TextEditingController(); // Kontrol input untuk username
  TextEditingController _passwordController = TextEditingController(); // Kontrol input untuk password
  bool _obscureText = true; // Variabel untuk mengontrol visibilitas password

  // Fungsi untuk memvalidasi inputan
  bool _validateInputs() {
    String username = _usernameController.text; // Mengambil nilai dari input username
    String password = _passwordController.text; // Mengambil nilai dari input password
    
    // Cek apakah username dan password tidak kosong dan memenuhi kondisi tertentu
    if (username.isEmpty || password.isEmpty) {
      return false; // Jika ada field yang kosong, kembalikan false
    }
    
    // Validasi password (misalnya, minimal 6 karakter)
    if (password.length < 6) {
      return false; // Jika password kurang dari 6 karakter, kembalikan false
    }

    return true; // Jika semua validasi lulus, kembalikan true
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0C4F5), Color(0xFF8993C9)], // Warna gradasi latar belakang
            begin: Alignment.topLeft, // Titik awal gradasi di pojok kiri atas
            end: Alignment.bottomRight, // Titik akhir gradasi di pojok kanan bawah
          ),
        ),
        child: Center(
          child: Container(
            width: 350, // Lebar kontainer utama
            padding: const EdgeInsets.all(20), // Padding di dalam kontainer
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3), // Latar belakang dengan opasitas
              borderRadius: BorderRadius.circular(20), // Membulatkan sudut kontainer
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Warna bayangan
                  blurRadius: 15, // Ukuran blur bayangan
                  spreadRadius: 5, // Ukuran sebaran bayangan
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Mengatur ukuran kolom agar sekecil mungkin
              crossAxisAlignment: CrossAxisAlignment.stretch, // Agar elemen kolom melebar
              children: [
                const CircleAvatar(
                  radius: 50, // Radius untuk avatar
                  backgroundColor: Colors.white, // Warna latar belakang avatar
                  child: Icon(
                    Icons.person, // Ikon orang
                    size: 50, // Ukuran ikon
                    color: Color.fromARGB(255, 164, 172, 216), // Warna ikon
                  ),
                ),
                const SizedBox(height: 20), // Spasi antara elemen
                const Text(
                  "Welcome to Our Website", // Teks judul
                  style: TextStyle(
                    fontSize: 18, // Ukuran font judul
                    fontWeight: FontWeight.bold, // Tebal font
                    color: Colors.black87, // Warna font
                  ),
                  textAlign: TextAlign.center, // Penyelarasan teks di tengah
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController, // Kontrol input username
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person), // Ikon untuk input username
                    hintText: "Username", // Placeholder untuk input username
                    filled: true, // Memberikan warna latar belakang
                    fillColor: Colors.white.withOpacity(0.8), // Warna latar belakang input
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Sudut border input
                      borderSide: BorderSide.none, // Menghilangkan garis border
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController, // Kontrol input password
                  obscureText: _obscureText, // Mengatur agar password disembunyikan atau tidak
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock), // Ikon kunci untuk password
                    hintText: "Password", // Placeholder untuk password
                    filled: true, // Memberikan warna latar belakang
                    fillColor: Colors.white.withOpacity(0.8), // Warna latar belakang input
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Sudut border input
                      borderSide: BorderSide.none, // Menghilangkan garis border
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility, // Ikon mata untuk toggle visibilitas password
                        color: Colors.grey, // Warna ikon
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText; // Toggle visibilitas password
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_validateInputs()) { // Memeriksa apakah input valid
                      // Navigasi ke halaman HomeScreen setelah login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    } else {
                      // Tampilkan SnackBar jika input tidak valid
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invalid username or password!"), // Pesan jika input salah
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Warna latar belakang tombol
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Sudut border tombol
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 7), // Padding tombol
                  ),
                  child: const Text(
                    "LOGIN", // Teks di tombol login
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 245, 247, 248)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
