import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';  // Pastikan LoginScreen terimport dengan benar

// Widget utama untuk tampilan HomeScreen
class HomeScreen extends StatefulWidget {
  final String username; // Nama akun pengguna yang login
  const HomeScreen({required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// State untuk HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client; // Inisialisasi SupabaseClient

  // Controller untuk TextField
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  // Fungsi untuk menambahkan produk ke database
  Future<void> _addProduct() async {
    final namaProduk = _namaProdukController.text.trim();
    final harga = double.tryParse(_hargaController.text.trim());
    final stok = int.tryParse(_stokController.text.trim());

    // Validasi input
    if (namaProduk.isEmpty || harga == null || stok == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data dengan benar!')),
      );
      return;
    }

    try {
      // Menambahkan produk ke tabel 'produk' di Supabase
      await _supabase.from('produk').insert({
        'namaproduk': namaProduk,
        'harga': harga,
        'stok': stok,
      });

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan!')),
      );

      // Kosongkan input setelah berhasil
      _namaProdukController.clear();
      _hargaController.clear();
      _stokController.clear();

      setState(() {}); // Refresh tampilan
    } catch (e) {
      // Menampilkan pesan error jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan produk: $e')),
      );
    }
  }

  // Fungsi untuk mengambil data produk dari database
  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      // Mengambil data produk dari tabel 'produk'
      final response = await _supabase.from('produk').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Menampilkan pesan error jika gagal memuat produk
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
      return [];
    }
  }

  // Fungsi untuk logout
  void _logout() {
    _supabase.auth.signOut(); // Logout dari Supabase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),  // Arahkan ke halaman Login
    );
  }

  // Konfirmasi logout dengan dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement( // Navigasi ke halaman login setelah logout
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()), // Pindah ke halaman LoginScreen
              );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir Cake Shop'),
        backgroundColor: Colors.pinkAccent,  // Warna background AppBar
        actions: [
          // Tombol logout di AppBar
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _showLogoutDialog, // Panggil dialog konfirmasi logout
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Header drawer dengan nama pengguna
            UserAccountsDrawerHeader(
              accountName: Text(widget.username),
              accountEmail: Text('kasir@cakeshop.com'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.pinkAccent),
              ),
              decoration: const BoxDecoration(
                color: Colors.pinkAccent,
              ),
            ),
            // Navigasi ke halaman Home
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // Navigasi ke halaman Transaksi
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Transaksi'),
              onTap: () {
                Navigator.pushNamed(context, '/transaksi');
              },
            ),
            // Navigasi ke halaman Produk
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Produk'),
              onTap: () {
                Navigator.pushNamed(context, '/produk');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),  // Padding sekitar konten
        child: Column(
          children: [
            // Input untuk Nama Produk
            TextField(
              controller: _namaProdukController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Input untuk Harga Produk
            TextField(
              controller: _hargaController,
              decoration: const InputDecoration(
                labelText: 'Harga',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            // Input untuk Stok Produk
            TextField(
              controller: _stokController,
              decoration: const InputDecoration(
                labelText: 'Stok',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Tombol untuk menambahkan produk
            ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,  // Warna tombol
              ),
              child: const Text('Tambah Produk'),
            ),
            const SizedBox(height: 20),
            // Menampilkan daftar produk
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(  // Mengambil data produk
                future: _fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada produk.'));
                  }

                  final products = snapshot.data!; // Daftar produk
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        child: ListTile(
                          title: Text(product['namaproduk']),  // Nama produk
                          subtitle: Text('Harga: ${product['harga']} | Stok: ${product['stok']}'),  // Detail produk
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
