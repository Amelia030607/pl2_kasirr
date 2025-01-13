import 'package:flutter/material.dart';
import 'home.dart'; // Pastikan untuk mengimpor HomeScreen, halaman tujuan setelah login

// Definisikan RegisterScreen di sini atau di file terpisah
class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Center(
        child: const Text("Register Screen"), // Ganti dengan UI registrasi yang sesuai
      ),
    );
  }
}

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
            colors: [Color(0xFFFFE4E1), Color(0xFFFFB6C1)], // Warna gradasi latar belakang
            begin: Alignment.topLeft, // Titik awal gradasi di pojok kiri atas
            end: Alignment.bottomRight, // Titik akhir gradasi di pojok kanan bawah
          ),
        ),
        child: Center(
          child: Container(
            width: 350, // Lebar kontainer utama
            padding: const EdgeInsets.all(20), // Padding di dalam kontainer
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5), // Latar belakang dengan opasitas
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
              mainAxisSize: MainAxisSize.min, // Mengatur ukuran kolom 
              crossAxisAlignment: CrossAxisAlignment.stretch, // Agar elemen kolom melebar
              children: [
                const CircleAvatar(
                  radius: 50, // Radius untuk avatar
                  backgroundColor: Colors.white, // Warna latar belakang avatar
                  child: Icon(
                    Icons.person, // Ikon orang
                    size: 50, // Ukuran ikon
                    color: Color.fromARGB(255, 255, 192, 203), // Warna ikon
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
                    backgroundColor: Color(0xFFFFC0CB), // Warna latar belakang tombol
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Sudut border tombol
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 7), // Padding tombol
                  ),
                  child: const Text(
                    "LOGIN", // Teks di tombol login
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman registrasi
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        const TextSpan(
                          text: "Don't have an account? ", // Teks yang pertama
                          style: TextStyle(color: Colors.black), // Warna hitam untuk teks pertama
                        ),
                        TextSpan(
                          text: "Register here", // Teks yang kedua
                          style: TextStyle(color: Colors.blue), // Warna biru untuk teks kedua
                        ),
                      ],
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
