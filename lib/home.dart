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
        TransaksiScreen(), // Halaman transaksi
        PenjualanScreen(role: widget.role), // Halaman riwayat penjualan
        PelangganScreen(), // Halaman pelanggan
        ProfilScreen(username: widget.username), // Halaman profil
      ];
    } else if (widget.role == 'pegawai') {
      _pages = [
        TransaksiScreen(),
        ProfilScreen(username: widget.username),
      ];
    } else if (widget.role == 'pelanggan') {
      _pages = [
        TransaksiScreen(),
        ProfilScreen(username: widget.username),
      ];
    } else {
      _pages = [ProfilScreen(username: widget.username)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir Cake Shop'), // Judul aplikasi
        backgroundColor: Colors.pinkAccent, // Warna header
        actions: [
          // Tombol registrasi untuk semua pengguna
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Daftar sebagai member', // Tooltip untuk memperjelas fungsi tombol
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout', // Tooltip untuk logout
            onPressed: () async {
              final shouldLogout = await _showLogoutConfirmationDialog();
              if (shouldLogout) {
                await Supabase.instance.client.auth.signOut(); // Logout dari Supabase
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Kembali ke halaman login
                );
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex, // Menampilkan halaman sesuai indeks yang dipilih
        children: _pages, // Daftar halaman yang ditampilkan
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Menandai indeks yang sedang aktif
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Mengubah indeks saat tombol navbar ditekan
          });
        },
        selectedItemColor: Colors.white, // Warna ikon yang dipilih
        unselectedItemColor: Colors.white70, // Warna ikon yang tidak dipilih
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: Colors.pinkAccent, // Warna navbar disamakan dengan header
        type: BottomNavigationBarType.fixed, // Menjaga posisi navbar tetap
        items: _buildNavBarItems(), // Menentukan daftar item navbar berdasarkan peran pengguna
      ),
    );
  }

  // Fungsi untuk menentukan item navbar berdasarkan peran pengguna
  List<BottomNavigationBarItem> _buildNavBarItems() {
    if (widget.role == 'admin') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Produk'),
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Transaksi'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Pelanggan'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else if (widget.role == 'pegawai') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Transaksi'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else if (widget.role == 'pelanggan') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Transaksi'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi logout
  Future<bool> _showLogoutConfirmationDialog() async {
    return (await showDialog<bool>(
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
                  onPressed: () {
                    Navigator.pop(context, true); // Konfirmasi logout
                  },
                  child: const Text('Keluar'),
                ),
              ],
            );
          },
        )) ??
        false;
  }
}
