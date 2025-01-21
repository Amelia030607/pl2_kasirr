import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

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

  // Menyimpan index halaman yang aktif
  int _currentIndex = 0;

  // Fungsi untuk mengambil data produk dari Supabase
  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      // Mengambil data produk dari tabel 'produk' di Supabase
      final response = await _supabase
          .from('produk')
          .select()
          .order('id_produk', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Menampilkan pesan error jika gagal mengambil data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
      return [];
    }
  }

  // Widget untuk menampilkan daftar produk dalam bentuk ListView
  Widget _buildProductList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchProducts(),
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
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(product['namaproduk']),
                subtitle: Text('Harga: ${product['harga']} | Stok: ${product['stok']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol untuk mengedit produk
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditDialog(product);
                      },
                    ),
                    // Tombol untuk menghapus produk
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmation(product['id_produk']);
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

  // Widget untuk halaman transaksi yang sedang dalam pengembangan
  Widget _buildTransactionPage() {
    return const Center(
      child: Text('Halaman Transaksi dalam pengembangan!'),
    );
  }

  // Widget untuk halaman profil yang menampilkan nama pengguna
  Widget _buildProfilePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.pinkAccent,
          ),
          const SizedBox(height: 20),
          Text(
            'Selamat datang, ${widget.username}',
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
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
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
      }).eq('id_produk', productId);

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
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(productId);
                Navigator.pop(context);
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
      await _supabase.from('produk').delete().eq('id_produk', productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus!')),
      );
      setState(() {});
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
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
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
            // Tombol untuk menyimpan produk
            ElevatedButton(
              onPressed: () {
                _addProduct(
                  _namaProdukController.text,
                  _hargaController.text,
                  _stokController.text,
                );
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

    // Validasi input pengguna
    if (namaProduk.isEmpty || hargaParsed == null || stokParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data dengan benar!')),
      );
      return;
    }

    try {
      // Menambahkan produk ke database
      await _supabase.from('produk').insert({
        'namaproduk': namaProduk,
        'harga': hargaParsed,
        'stok': stokParsed,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan!')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan produk: $e')),
      );
    }
  }

  // Fungsi untuk menampilkan konfirmasi logout
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Pindah ke halaman login jika logout
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Widget untuk membangun tampilan halaman utama
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
            onPressed: _showLogoutConfirmation,
          ),
        ],
      ),
      // Menampilkan halaman yang sesuai dengan index yang dipilih
      body: _currentIndex == 0
          ? _buildProductList()
          : _currentIndex == 1
              ? _buildTransactionPage()
              : _buildProfilePage(),
      // Floating action button untuk menambah produk
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
      // Bottom navigation bar untuk berpindah antar halaman
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
