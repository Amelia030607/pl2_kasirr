import 'package:flutter/material.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'home.dart'; 


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState(); 
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(); // Kontrol untuk input email
  final TextEditingController _passwordController = TextEditingController(); // Kontrol untuk input password
  bool _obscureText = true; // Variabel untuk mengontrol visibilitas password

  // Fungsi untuk menangani login
  Future<void> _login() async {
    final email = _emailController.text.trim(); // Mengambil nilai email dan menghapus spasi di awal/akhir
    final password = _passwordController.text.trim(); // Mengambil nilai password dan menghapus spasi di awal/akhir

    // Validasi jika email atau password kosong
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email dan password tidak boleh kosong')), 
      );
      return;
    }

    try {
      // Query ke tabel 'user' di Supabase untuk mencocokkan email dan password
      final response = await Supabase.instance.client
          .from('user')
          .select('role') // Memilih kolom role untuk menentukan peran pengguna
          .eq('email', email) // Kondisi untuk mencocokkan email
          .eq('password', password) // Kondisi untuk mencocokkan password
          .maybeSingle(); // Mengambil hasil tunggal atau null jika tidak ada

      // Jika tidak ditemukan data yang cocok
      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal! Email atau password salah.')), // Menampilkan pesan kesalahan
        );
        return;
      }

      final role = response['role']; // Mengambil peran pengguna dari hasil query

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login berhasil! Selamat datang $email')), // Menampilkan pesan sukses
      );

      // Navigasi ke halaman HomeScreen dengan username dan role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(username: email, role: role),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')), // Menampilkan pesan kesalahan jika ada exception
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100, 
      body: Center(
        child: SingleChildScrollView( // Mengizinkan layar untuk menggulir jika kontennya panjang
          child: Container(
            padding: const EdgeInsets.all(20), // Margin dalam untuk kontainer
            width: 350, // Lebar kontainer
            decoration: BoxDecoration(
              color: Colors.white, // Warna latar belakang kontainer
              borderRadius: BorderRadius.circular(20), // Membuat sudut membulat
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Warna bayangan dengan opasitas 10%
                  blurRadius: 10, // Radius bayangan
                  offset: const Offset(0, 5), // Posisi bayangan
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ukuran kolom menyesuaikan isi
              children: [
                const CircleAvatar(
                  radius: 50, // Ukuran lingkaran
                  backgroundColor: Colors.pinkAccent, // Warna latar lingkaran
                  child: Icon(Icons.person, size: 50, color: Colors.white), // Ikon pengguna di dalam lingkaran
                ),
                const SizedBox(height: 20), // Jarak antar elemen
                const Text(
                  "WELCOME TO OUR WEBSITE", 
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 20), // Jarak antar elemen
                TextField(
                  controller: _emailController, // Menghubungkan input dengan kontrol email
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.pinkAccent), 
                    hintText: 'Email', // Placeholder untuk input
                    filled: true, // Mengisi latar belakang kotak input
                    fillColor: Colors.pink.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Membuat sudut membulat
                      borderSide: BorderSide.none, // Menghapus border default
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Jarak antar elemen
                TextField(
                  controller: _passwordController, // Menghubungkan input dengan kontrol password
                  obscureText: _obscureText, // Menentukan apakah password disembunyikan atau tidak
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.pinkAccent), 
                    hintText: 'Password', // Placeholder untuk input
                    filled: true, // Mengisi latar belakang kotak input
                    fillColor: Colors.pink.shade50, 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Membuat sudut membulat
                      borderSide: BorderSide.none, // Menghapus border default
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility, // Ikon untuk menunjukkan atau menyembunyikan password
                        color: Colors.pinkAccent, // Warna ikon
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText; // Mengubah visibilitas password
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Jarak antar elemen
                SizedBox(
                  width: double.infinity, // Memastikan tombol memiliki lebar penuh
                  child: ElevatedButton(
                    onPressed: _login, // Fungsi login dipanggil saat tombol ditekan
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent, // Warna tombol
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Membuat sudut membulat
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15), // Padding vertikal tombol
                    ),
                    child: const Text(
                      'LOGIN', 
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
