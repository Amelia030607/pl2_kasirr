import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk form validasi
  final _emailController = TextEditingController(); // Controller untuk input email
  final _passwordController = TextEditingController(); // Controller untuk input password
  bool _isLoading = false; // Status untuk menunjukkan apakah proses loading sedang berlangsung
  bool _isPasswordVisible = false; // Untuk mengontrol visibilitas password

  // Fungsi untuk melakukan registrasi
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return; // Jika form tidak valid, hentikan proses

    setState(() {
      _isLoading = true; // Tampilkan indikator loading
    });

    final email = _emailController.text.trim(); // Ambil email dari controller dan hapus spasi
    final password = _passwordController.text.trim(); // Ambil password dari controller dan hapus spasi

    try {
      final supabase = Supabase.instance.client;

      // Cek apakah email sudah digunakan
      final existingUser = await supabase
          .from('user')
          .select('email') // Pilih kolom email
          .eq('email', email) // Cek apakah email sudah ada di database
          .maybeSingle(); // Ambil data tunggal jika ada

      if (existingUser != null) {
        // Jika email sudah terdaftar, tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email sudah terdaftar!')),
        );
      } else {
        // Jika email belum terdaftar, cari ID terbesar dan tambahkan 1
        final maxIdData = await supabase
            .from('user')
            .select('id') // Pilih kolom id
            .order('id', ascending: false) // Urutkan berdasarkan ID terbesar
            .limit(1) // Ambil hanya 1 data
            .maybeSingle(); // Ambil data tunggal jika ada

        int newId = (maxIdData != null && maxIdData['id'] != null)
            ? (maxIdData['id'] as int) + 1 // Tambahkan 1 pada ID terbesar
            : 1; // Jika tidak ada data ID, mulai dari 1

        // Insert data user baru ke dalam tabel 'user'
        await supabase.from('user').insert({
          'id': newId, // ID baru yang dihasilkan
          'email': email, // Email dari input
          'password': password, // Password dari input
          'role': 'pelanggan', // Role sebagai pelanggan
          'created_at': DateTime.now().toIso8601String(), // Tanggal pembuatan akun
        });

        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Anda menjadi member dan mendapatkan diskon 15%')),
        );

        // Kembali ke halaman sebelumnya setelah registrasi sukses
        Navigator.pop(context);
      }
    } catch (error) {
      // Jika terjadi error, tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi gagal: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set status loading ke false setelah proses selesai
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Member'), 
        backgroundColor: Colors.pinkAccent, 
      ),
      body: Container(
        color: Colors.pink[50], 
        padding: const EdgeInsets.all(20.0), // Padding di seluruh body
        child: Form(
          key: _formKey, // Menyambungkan form dengan kunci untuk validasi
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Menyusun elemen secara horizontal di tengah
            children: [
              // Input untuk email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(), // Border untuk field
                  prefixIcon: Icon(Icons.email), // Ikon untuk field email
                ),
                keyboardType: TextInputType.emailAddress, // Mengatur jenis keyboard menjadi email
                validator: (value) => value!.isEmpty ? 'Masukkan email yang valid' : null, // Validasi email
              ),
              const SizedBox(height: 15), 
              // Input untuk password
              TextFormField(
                controller: _passwordController, 
                obscureText: !_isPasswordVisible, // Menentukan apakah password disembunyikan atau tidak
                decoration: InputDecoration(
                  labelText: 'Password', 
                  border: OutlineInputBorder(), // Border untuk field
                  prefixIcon: Icon(Icons.lock), // Ikon untuk field password
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility // Ikon mata terbuka jika password terlihat
                          : Icons.visibility_off, // Ikon mata tertutup jika password disembunyikan
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible; // Toggle visibilitas password
                      });
                    },
                  ),
                ),
                validator: (value) => value!.length < 6 ? 'Password minimal 6 karakter' : null, // Validasi password
              ),
              const SizedBox(height: 20), 
              // Tombol untuk melakukan registrasi
              _isLoading
                  ? CircularProgressIndicator() // Menampilkan indikator loading jika sedang proses
                  : ElevatedButton(
                      onPressed: _register, // Panggil fungsi registrasi saat tombol ditekan
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent), 
                      child: const Text('Daftar Member', style: TextStyle(color: Colors.white)), 
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
