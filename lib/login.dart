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
  String? _emailError; // Variabel untuk menyimpan pesan error email
  String? _passwordError; // Variabel untuk menyimpan pesan error password

  Future<void> _login() async {
    final email = _emailController.text.trim(); // Mengambil nilai email dengan menghapus spasi di awal/akhir
    final password = _passwordController.text.trim(); // Mengambil nilai password dengan menghapus spasi di awal/akhir
    setState(() {
      _emailError = null; // Reset error email
      _passwordError = null; // Reset error password
    });

    if (email.isEmpty && password.isEmpty) { // Jika email dan password kosong
      setState(() {
        _emailError = 'Email wajib terisi';
        _passwordError = 'Password wajib terisi';
      });
      return;
    }
    if (email.isEmpty) { // Jika hanya email kosong
      setState(() {
        _emailError = 'Email tidak boleh kosong';
      });
      return;
    }

    if (password.isEmpty) { // Jika hanya password kosong
      setState(() {
        _passwordError = 'Password tidak boleh kosong';
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('user')
          .select('email, password, role')
          .eq('email', email)
          .maybeSingle(); // Mengambil satu data pengguna berdasarkan email

      if (response == null) { // Jika email tidak ditemukan
        setState(() {
          _emailError = 'Email salah';
        });
        return;
      }

      if (response['password'] != password) { // Jika password salah
        setState(() {
          _passwordError = 'Password salah';
        });
        return;
      }

      final role = response['role']; // Mengambil peran pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login berhasil! Selamat datang $email')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(username: email, role: role),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100, // Warna latar belakang halaman login
      body: Center(
        child: SingleChildScrollView( // Agar tampilan bisa di-scroll jika kontennya panjang
          child: Container(
            padding: const EdgeInsets.all(20), // Padding dalam kontainer
            width: 350, // Lebar kontainer login
            decoration: BoxDecoration(
              color: Colors.white, // Warna latar belakang kontainer
              borderRadius: BorderRadius.circular(20), // Membuat sudut kontainer membulat
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Warna bayangan
                  blurRadius: 10, // Radius blur bayangan
                  offset: const Offset(0, 5), // Posisi bayangan
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Kolom menyesuaikan ukuran sesuai isi
              children: [
                const CircleAvatar(
                  radius: 50, // Ukuran lingkaran avatar
                  backgroundColor: Colors.pinkAccent, // Warna latar belakang avatar
                  child: Icon(Icons.person, size: 50, color: Colors.white), // Ikon avatar
                ),
                const SizedBox(height: 20), // Jarak antar elemen
                const Text(
                  "SELAMAT DATANG DIKASIR CAKE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController, // Controller untuk email
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.pinkAccent),
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.pink.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _emailError, // Menampilkan pesan error email jika ada
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController, // Controller untuk password
                  obscureText: _obscureText, // Mengontrol visibilitas password
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.pinkAccent),
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.pink.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _passwordError, // Menampilkan pesan error password jika ada
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.pinkAccent,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login, // Memanggil fungsi login saat tombol ditekan
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent, // Warna tombol
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
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
