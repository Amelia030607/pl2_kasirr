import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart'; // Mengimpor halaman login
import 'transaksi.dart'; // Mengimpor halaman transaksi

class HomeScreen extends StatefulWidget {
  // Menerima parameter username dari halaman sebelumnya
  final String username;

  const HomeScreen({required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Membuat instance SupabaseClient untuk mengakses database
  final SupabaseClient _supabase = Supabase.instance.client;

  // Menyimpan index halaman yang aktif (0: Produk, 1: Transaksi, 2: Profil)
  int _currentIndex = 0;

  // Fungsi untuk mengambil data produk dari Supabase
  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      // Mengambil data produk dari tabel 'produk' di Supabase
      final response = await _supabase
          .from('produk')
          .select()
          .order('id_produk', ascending: true); // Mengurutkan produk berdasarkan id_produk
      return List<Map<String, dynamic>>.from(response); // Mengonversi hasil response menjadi list
    } catch (e) {
      // Menampilkan pesan error jika gagal mengambil data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
      return []; // Mengembalikan list kosong jika gagal
    }
  }

  // Widget untuk menampilkan daftar produk dalam bentuk ListView
  Widget _buildProductList() {
    return FutureBuilder<List<Map<String, dynamic>>>( // Menggunakan FutureBuilder untuk menunggu hasil fetch produk
      future: _fetchProducts(), // Memanggil fungsi _fetchProducts untuk mengambil data produk
      builder: (context, snapshot) {
        // Menampilkan loading indicator saat data sedang diambil
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } 
        // Menampilkan error jika terjadi kesalahan
        else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } 
        // Menampilkan pesan jika tidak ada produk
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada produk.'));
        }

        final products = snapshot.data!; // Mengambil data produk

        // Menampilkan produk dalam bentuk ListView
        return ListView.builder(
          itemCount: products.length, // Jumlah item sesuai dengan banyaknya produk
          itemBuilder: (context, index) {
            final product = products[index]; // Mengambil data produk per index
            return Card(
              elevation: 5, // Memberikan efek bayangan pada kartu
              margin: const EdgeInsets.symmetric(vertical: 5), // Margin antar item
              child: ListTile(
                title: Text(product['namaproduk']), // Menampilkan nama produk
                subtitle: Text('Harga: ${product['harga']} | Stok: ${product['stok']}'), // Menampilkan harga dan stok produk
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol untuk mengedit produk
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditDialog(product); // Memanggil fungsi untuk menampilkan dialog edit produk
                      },
                    ),
                    // Tombol untuk menghapus produk
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.redAccent,
                      onPressed: () {
                        _showDeleteConfirmation(product['id_produk']); // Memanggil fungsi konfirmasi hapus produk
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Fungsi untuk halaman transaksi yang sudah dibuat di transaksi.dart
  Widget _buildTransactionPage() {
    return const TransaksiScreen(); // Mengembalikan widget halaman transaksi
  }

  // Widget untuk halaman profil yang menampilkan nama pengguna
  Widget _buildProfilePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle, // Ikon untuk profil
            size: 100,
            color: Colors.pinkAccent,
          ),
          const SizedBox(height: 20),
          Text(
            'Selamat datang, ${widget.username}', // Menampilkan nama pengguna dari parameter
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan dialog edit produk
  void _showEditDialog(Map<String, dynamic> product) {
    final TextEditingController _namaProdukController = TextEditingController(text: product['namaproduk']);
    final TextEditingController _hargaController = TextEditingController(text: product['harga'].toString());
    final TextEditingController _stokController = TextEditingController(text: product['stok'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaProdukController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number, // Menggunakan keyboard angka
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number, // Menggunakan keyboard angka
              ),
            ],
          ),
          actions: [
            // Tombol untuk membatalkan perubahan
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            // Tombol untuk menyimpan perubahan
            ElevatedButton(
              onPressed: () {
                _updateProduct(product['id_produk'], _namaProdukController.text, _hargaController.text, _stokController.text);
                Navigator.pop(context);
              },
              child: const Text('Perbarui Data'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk memperbarui produk di database
  Future<void> _updateProduct(int productId, String namaProduk, String harga, String stok) async {
    final hargaParsed = double.tryParse(harga);
    final stokParsed = int.tryParse(stok);

    // Validasi input pengguna
    if (namaProduk.isEmpty || hargaParsed == null || stokParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data dengan benar!')),
      );
      return;
    }

    try {
      // Melakukan update data produk di database
      await _supabase.from('produk').update({
        'namaproduk': namaProduk,
        'harga': hargaParsed,
        'stok': stokParsed,
      }).eq('id_produk', productId); // Menentukan produk yang akan diperbarui berdasarkan id_produk

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diperbarui!')),
      );
      setState(() {}); // Memperbarui tampilan
    } catch (e) {
      // Menampilkan pesan error jika gagal update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk: $e')),
      );
    }
  }

  // Fungsi untuk menampilkan konfirmasi penghapusan produk
  void _showDeleteConfirmation(int productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Membatalkan penghapusan
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(productId); // Memanggil fungsi untuk menghapus produk
                Navigator.pop(context); // Menutup dialog
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus produk dari database
  Future<void> _deleteProduct(int productId) async {
    try {
      await _supabase.from('produk').delete().eq('id_produk', productId); // Menghapus produk berdasarkan id_produk
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus!')),
      );
      setState(() {}); // Memperbarui tampilan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk: $e')),
      );
    }
  }

  // Fungsi untuk menampilkan dialog menambah produk
  void _showAddProductDialog() {
    final TextEditingController _namaProdukController = TextEditingController();
    final TextEditingController _hargaController = TextEditingController();
    final TextEditingController _stokController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaProdukController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number, // Menggunakan keyboard angka
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number, // Menggunakan keyboard angka
              ),
            ],
          ),
          actions: [
            // Tombol untuk membatalkan penambahan produk
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            // Tombol untuk menyimpan produk baru
            ElevatedButton(
              onPressed: () {
                _addProduct(_namaProdukController.text, _hargaController.text, _stokController.text);
                Navigator.pop(context);
              },
              child: const Text('Tambah Produk'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menambahkan produk ke database
  Future<void> _addProduct(String namaProduk, String harga, String stok) async {
    final hargaParsed = double.tryParse(harga);
    final stokParsed = int.tryParse(stok);

    // Validasi input
    if (namaProduk.isEmpty || hargaParsed == null || stokParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data dengan benar!')),
      );
      return;
    }

    try {
      // Menambahkan produk ke dalam database
      await _supabase.from('produk').insert({
        'namaproduk': namaProduk,
        'harga': hargaParsed,
        'stok': stokParsed,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan!')),
      );
      setState(() {}); // Memperbarui tampilan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan produk: $e')),
      );
    }
  }

  // Menampilkan halaman sesuai dengan index yang dipilih di navbar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir Cake Shop'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          // Tombol untuk logout
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              final shouldLogout = await _showLogoutConfirmationDialog();
              if (shouldLogout) {
                // Menghapus session login dan kembali ke halaman login
                await Supabase.instance.client.auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _currentIndex == 0
          ? _buildProductList() // Menampilkan daftar produk
          : _currentIndex == 1
              ? _buildTransactionPage() // Menampilkan halaman transaksi
              : _buildProfilePage(), // Menampilkan halaman profil
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Mengubah halaman yang aktif sesuai index
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 // Menampilkan tombol tambah produk hanya di halaman produk
          ? FloatingActionButton(
              onPressed: _showAddProductDialog,
              child: const Icon(Icons.add),
              backgroundColor: Colors.pinkAccent,
              tooltip: 'Tambah Produk',
            )
          : null,
    );
  }

  // Menampilkan dialog konfirmasi logout
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
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
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