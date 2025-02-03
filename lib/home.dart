import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'transaksi.dart';
import 'pelanggan.dart';
import 'produk.dart';
import 'penjualan.dart';
import 'profil.dart';
import 'register.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String role;

  const HomeScreen({required this.username, required this.role});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Indeks halaman yang aktif
  late final List<Widget> _pages; // Daftar halaman yang akan ditampilkan berdasarkan peran pengguna

  @override
  void initState() {
    super.initState();

    // Menentukan halaman yang dapat diakses berdasarkan peran pengguna
    if (widget.role == 'admin') {
      _pages = [
        ProdukScreen(), // Halaman produk
        PenjualanScreen(), // Halaman riwayat penjualan
        PelangganScreen(), // Halaman pelanggan
        RegisterScreen(), // Halaman registrasi untuk admin
        ProfilScreen(username: widget.username), // Halaman profil
      ];
    } else if (widget.role == 'pegawai') {
      _pages = [
        TransaksiScreen(), // Halaman transaksi
        PenjualanScreen(), // Halaman riwayat penjualan
        ProfilScreen(username: widget.username), // Halaman profil
      ];
    } else {
      _pages = [ProfilScreen(username: widget.username)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Menampilkan halaman sesuai indeks yang dipilih
        children: _pages, // Daftar halaman yang ditampilkan
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Menandai indeks yang sedang aktif
        selectedItemColor: Colors.white, // Warna ikon yang dipilih
        unselectedItemColor: Colors.white70, // Warna ikon yang tidak dipilih
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: Colors.pinkAccent, // Warna navbar disamakan dengan header
        type: BottomNavigationBarType.fixed, // Menjaga posisi navbar tetap
        items: _buildNavBarItems(), // Menentukan daftar item navbar berdasarkan peran pengguna
        onTap: (index) {
          // Jika yang dipilih adalah logout
          if (index == _buildNavBarItems().length - 1) {
            _showLogoutConfirmationDialog(); // Menampilkan dialog konfirmasi logout
          } else {
            setState(() {
              _currentIndex = index; // Menangani perubahan halaman selain logout
            });
          }
        },
      ),
    );
  }

  // Fungsi untuk menentukan item navbar berdasarkan peran pengguna
  List<BottomNavigationBarItem> _buildNavBarItems() {
    if (widget.role == 'admin') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Produk'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Pelanggan'),
        BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Registrasi'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Logout'), // Tombol logout
      ];
    } else if (widget.role == 'pegawai') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Transaksi'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Logout'), // Tombol logout
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Logout'), // Tombol logout
      ];
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi logout
  Future<void> _showLogoutConfirmationDialog() async {
    final shouldLogout = await showDialog<bool>( 
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'), 
          content: const Text('Apakah Anda yakin ingin keluar?'), 
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Tutup dialog tanpa logout
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut(); // Logout dari Supabase
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Kembali ke halaman login
                );
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    ) ?? false;

    if (shouldLogout) {
      await Supabase.instance.client.auth.signOut(); // Logout dari Supabase
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Kembali ke halaman login
      );
    }
  }
}
