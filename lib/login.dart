import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(); // Controller untuk input email
  final TextEditingController _passwordController = TextEditingController(); // Controller untuk input password
  bool _obscureText = true; // Untuk mengatur visibilitas password (apakah tersembunyi atau tidak)

  // Fungsi untuk menangani login
  void _login() async {
    final email = _emailController.text.trim(); // Mengambil dan membersihkan input email
    final password = _passwordController.text.trim(); // Mengambil dan membersihkan input password

    // Validasi jika email atau password kosong
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email dan password tidak boleh kosong')), // Menampilkan pesan error
      );
      return; // Menghentikan proses login
    }

    try {
      // Query ke tabel user di Supabase untuk mencocokkan email dan password
      final response = await Supabase.instance.client
          .from('user') // Tabel `user` di Supabase
          .select() // Melakukan query SELECT
          .eq('email', email) // Filter berdasarkan email
          .eq('password', password) // Filter berdasarkan password
          .maybeSingle(); // Mengambil 1 data (null jika tidak ditemukan)

      if (response == null) {
        // Jika data tidak ditemukan (email/password salah)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal! Email atau password salah.')), // Pesan login gagal
        );
      } else {
        // Jika data ditemukan (login berhasil)
        final userData = response; // Data pengguna
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login berhasil! Selamat datang ${userData['email']}')), // Pesan login berhasil
        );

        // Navigasi ke halaman Home
        Navigator.pushReplacementNamed(
          context,
          '/home', // Rute halaman Home
          arguments: userData, // Kirim data pengguna ke halaman berikutnya
        );
      }
    } catch (e) {
      // Penanganan kesalahan jika query gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')), // Menampilkan pesan error
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100, // Warna latar belakang
      body: Center(
        child: SingleChildScrollView( // Untuk menggulirkan konten jika layar kecil
          child: Container(
            padding: const EdgeInsets.all(20), // Padding di sekitar form
            width: 350, // Lebar form
            decoration: BoxDecoration(
              color: Colors.white, // Warna latar belakang form
              borderRadius: BorderRadius.circular(20), // Membuat sudut form melengkung
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Bayangan form
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Meminimalkan ukuran kolom agar sesuai konten
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.pinkAccent, // Warna latar belakang avatar
                  child: Icon(
                    Icons.person, // Ikon avatar
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20), // Jarak antara avatar dan teks
                const Text(
                  "WELCOME TO OUR WEBSITE", // Teks sambutan
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent, // Warna teks
                  ),
                ),
                const SizedBox(height: 20), // Jarak antara teks dan form email
                TextField(
                  controller: _emailController, // Controller untuk input email
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.pinkAccent), // Ikon input email
                    hintText: 'Email', // Placeholder untuk email
                    filled: true,
                    fillColor: Colors.pink.shade50, // Warna latar belakang input
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Membuat sudut input melengkung
                      borderSide: BorderSide.none, // Menghilangkan border
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Jarak antara form email dan password
                TextField(
                  controller: _passwordController, // Controller untuk input password
                  obscureText: _obscureText, // Mengatur apakah password tersembunyi
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.pinkAccent), // Ikon input password
                    hintText: 'Password', // Placeholder untuk password
                    filled: true,
                    fillColor: Colors.pink.shade50, // Warna latar belakang input
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Membuat sudut input melengkung
                      borderSide: BorderSide.none, // Menghilangkan border
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility, // Ikon visibilitas password
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
                const SizedBox(height: 20), // Jarak antara input password dan tombol login
                SizedBox(
                  width: double.infinity, // Membuat tombol memenuhi lebar form
                  child: ElevatedButton(
                    onPressed: _login, // Fungsi login akan dipanggil saat tombol diklik
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent, // Warna tombol login
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Membuat sudut tombol melengkung
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15), // Padding vertikal tombol
                    ),
                    child: const Text(
                      'LOGIN', // Teks pada tombol login
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
