import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState(); // Membuat state untuk widget ini
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk kolom email dan password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Boolean untuk mengatur visibilitas password
  bool _obscureText = true;

  // Data dummy pengguna (email dan password)
  final List<Map<String, String>> _dummyUsers = [
    {
      "email": "amelia@gmail.com",
      "password": "123456789",
    },
    {
      "email": "admin@gmail.com",
      "password": "admin123",
    },
    {
      "email": "riski@gmail.com",
      "password": "riski123",
    },
  ];

  // Fungsi untuk menangani proses login
  void _login() {
    // Mengambil teks dari kolom email dan password
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Variabel untuk melacak apakah login berhasil
    bool isAuthenticated = false;

    // Memeriksa apakah email dan password yang dimasukkan cocok dengan pengguna dalam data dummy
    for (var user in _dummyUsers) {
      if (user['email'] == email && user['password'] == password) {
        isAuthenticated = true; // Pengguna terautentikasi
        break;
      }
    }

    // Jika autentikasi berhasil, navigasi ke halaman utama
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');  // Pindah ke halaman Home
    } else {
      // Jika autentikasi gagal, tampilkan pesan kesalahan dengan menggunakan snack bar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal! Email atau password salah.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Membangun UI widget
    return Scaffold(
      backgroundColor: Colors.pink.shade100, // Mengatur warna latar belakang layar
      body: Center(
        child: SingleChildScrollView( // Memungkinkan scroll jika keyboard muncul
          child: Container(
            padding: const EdgeInsets.all(20), // Memberikan padding di sekitar kontainer
            width: 350, // Lebar kontainer
            decoration: BoxDecoration(
              color: Colors.white, // Warna latar belakang kontainer
              borderRadius: BorderRadius.circular(20), // Sudut bulat pada kontainer
              boxShadow: [ // Menambahkan bayangan pada kontainer
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Warna bayangan dengan opasitas
                  blurRadius: 10, // Jarak blur bayangan
                  offset: const Offset(0, 5), // Posisi bayangan
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Meminimalkan ukuran kolom
              children: [
                const CircleAvatar( // Avatar lingkaran untuk ikon profil
                  radius: 50,
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20), // Spasi antara elemen
                const Text(
                  "WELCOME TO OUR WEBSITE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 20), // Spasi antara elemen
                TextField(
                  controller: _emailController, // Controller untuk kolom email
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.pinkAccent), // Ikon sebelum kolom input
                    hintText: 'Username', // Teks placeholder
                    filled: true,
                    fillColor: Colors.pink.shade50, // Warna latar belakang kolom input
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Sudut bulat untuk kolom input
                      borderSide: BorderSide.none, // Tanpa garis tepi
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Spasi antara elemen
                TextField(
                  controller: _passwordController, // Controller untuk kolom password
                  obscureText: _obscureText, // Mengatur apakah password terlihat atau tidak
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.pinkAccent), // Ikon sebelum kolom input
                    hintText: 'Password', // Teks placeholder
                    filled: true,
                    fillColor: Colors.pink.shade50, // Warna latar belakang kolom input
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Sudut bulat untuk kolom input
                      borderSide: BorderSide.none, // Tanpa garis tepi
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility, // Ikon toggle visibilitas password
                        color: Colors.pinkAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText; // Mengubah status visibilitas password
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Spasi antara elemen
                SizedBox(
                  width: double.infinity, // Membuat lebar tombol memenuhi ruang yang tersedia
                  child: ElevatedButton(
                    onPressed: _login, // Memanggil fungsi login saat tombol ditekan
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent, // Warna tombol
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Sudut bulat untuk tombol
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15), // Padding vertikal untuk tombol
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(fontSize: 16, color: Colors.white), // Gaya teks tombol
                    ),
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
