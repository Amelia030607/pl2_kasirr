import 'package:flutter/material.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'login.dart';

class HomeScreen extends StatefulWidget { // Membuat widget HomeScreen dengan parameter username.
  final String username;
  const HomeScreen({required this.username}); // Konstruktor untuk menerima username.

  @override
  _HomeScreenState createState() => _HomeScreenState(); // Membuat instance dari state untuk HomeScreen.
}

class _HomeScreenState extends State<HomeScreen> { // State untuk HomeScreen.
  final SupabaseClient _supabase = Supabase.instance.client; // Inisialisasi Supabase Client untuk mengakses database.

  final TextEditingController _namaProdukController = TextEditingController(); // Controller untuk nama produk.
  final TextEditingController _hargaController = TextEditingController(); // Controller untuk harga produk.
  final TextEditingController _stokController = TextEditingController(); // Controller untuk stok produk.

  int _currentIndex = 0; // Menyimpan index tab yang aktif (produk atau tambah produk).
  int? _selectedProductId; // Menyimpan id produk yang sedang diedit.

  // Fungsi untuk menambah produk baru.
  Future<void> _addProduct() async {
    final namaProduk = _namaProdukController.text.trim(); // Mendapatkan nama produk.
    final harga = double.tryParse(_hargaController.text.trim()); // Mendapatkan harga dan mencoba mengonversinya ke double.
    final stok = int.tryParse(_stokController.text.trim()); // Mendapatkan stok dan mencoba mengonversinya ke integer.

    // Validasi input.
    if (namaProduk.isEmpty || harga == null || stok == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data dengan benar!')), // Menampilkan pesan jika input tidak valid.
      );
      return; // Jika input tidak valid, keluar dari fungsi.
    }

    try {
      // Menambahkan data produk ke database Supabase.
      await _supabase.from('produk').insert({
        'namaproduk': namaProduk,
        'harga': harga,
        'stok': stok,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan!')), // Menampilkan pesan sukses.
      );

      // Mengosongkan controller setelah menambah produk.
      _namaProdukController.clear();
      _hargaController.clear();
      _stokController.clear();

      // Pindah ke halaman produk (menggunakan pushReplacement).
      setState(() {
        _currentIndex = 0; // Ganti tab ke daftar produk.
      });
    } catch (e) {
      // Menangani error jika terjadi masalah saat menambah produk.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan produk: $e')), // Menampilkan pesan error.
      );
    }
  }

  // Fungsi untuk memperbarui data produk.
  Future<void> _updateProduct(int productId) async {
    final namaProduk = _namaProdukController.text.trim();
    final harga = double.tryParse(_hargaController.text.trim());
    final stok = int.tryParse(_stokController.text.trim());

    // Validasi input.
    if (namaProduk.isEmpty || harga == null || stok == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data dengan benar!')), // Menampilkan pesan jika input tidak valid.
      );
      return;
    }

    try {
      // Mengupdate data produk di database Supabase berdasarkan id.
      await _supabase.from('produk').update({
        'namaproduk': namaProduk,
        'harga': harga,
        'stok': stok,
      }).eq('id_produk', productId); // Menggunakan eq untuk memilih produk berdasarkan id.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diperbarui!')), // Menampilkan pesan sukses.
      );

      // Mengosongkan controller setelah memperbarui produk.
      _namaProdukController.clear();
      _hargaController.clear();
      _stokController.clear();
      setState(() {
        _selectedProductId = null; // Reset id produk yang sedang diedit.
        _currentIndex = 0; // Kembali ke halaman daftar produk.
      });
    } catch (e) {
      // Menangani error saat memperbarui produk.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk: $e')), // Menampilkan pesan error.
      );
    }
  }

  // Fungsi untuk menghapus produk.
  Future<void> _deleteProduct(int productId) async {
    try {
      // Menghapus produk dari database Supabase berdasarkan id.
      await _supabase.from('produk').delete().eq('id_produk', productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus!')), // Menampilkan pesan sukses.
      );
      setState(() {}); // Refresh daftar produk setelah penghapusan.
    } catch (e) {
      // Menangani error saat menghapus produk.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk: $e')), // Menampilkan pesan error.
      );
    }
  }

  // Fungsi untuk mengambil data produk dari database.
  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      // Mengambil data produk dari Supabase.
      final response = await _supabase.from('produk').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Menangani error saat mengambil data produk.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')), // Menampilkan pesan error.
      );
      return [];
    }
  }

  // Fungsi untuk membangun daftar produk.
  Widget _buildProductList() {
    return FutureBuilder<List<Map<String, dynamic>>>( // Menggunakan FutureBuilder untuk menunggu data produk.
      future: _fetchProducts(), // Mengambil produk dari database.
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Menampilkan indikator loading saat data masih diambil.
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Menampilkan pesan error jika terjadi masalah.
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada produk.')); // Menampilkan pesan jika tidak ada data produk.
        }

        final products = snapshot.data!; // Mengambil data produk dari snapshot.
        return ListView.builder( // Menampilkan daftar produk dalam ListView.
          itemCount: products.length, // Jumlah produk.
          itemBuilder: (context, index) {
            final product = products[index]; // Mengambil produk berdasarkan index.
            return Card( // Menampilkan card untuk setiap produk.
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile( // Menampilkan data produk dalam ListTile.
                title: Text(product['namaproduk']),
                subtitle: Text('Harga: ${product['harga']} | Stok: ${product['stok']}'),
                trailing: Row( // Menambahkan ikon untuk edit dan delete produk.
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditDialog(product); // Menampilkan dialog edit produk.
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmation(product['id_produk']); // Menampilkan konfirmasi hapus produk.
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

  // Fungsi untuk menampilkan dialog edit produk.
  void _showEditDialog(Map<String, dynamic> product) {
    _namaProdukController.text = product['namaproduk'];
    _hargaController.text = product['harga'].toString();
    _stokController.text = product['stok'].toString();

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
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Menutup dialog tanpa menyimpan perubahan.
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateProduct(product['id_produk']); // Memperbarui produk.
                Navigator.pop(context); // Menutup dialog setelah update.
              },
              child: const Text('Perbarui Data'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan konfirmasi hapus produk.
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
                Navigator.pop(context); // Menutup dialog.
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(productId); // Menghapus produk.
                Navigator.pop(context); // Menutup dialog setelah menghapus.
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk membangun form tambah atau update produk.
  Widget _buildAddProductForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _namaProdukController,
            decoration: const InputDecoration(
              labelText: 'Nama Produk',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _hargaController,
            decoration: const InputDecoration(
              labelText: 'Harga',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _stokController,
            decoration: const InputDecoration(
              labelText: 'Stok',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selectedProductId == null
                ? _addProduct
                : () => _updateProduct(_selectedProductId!), // Menambah atau memperbarui produk.
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent, // Warna tombol.
            ),
            child: Text(_selectedProductId == null ? 'Tambah Produk' : 'Perbarui Produk'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan konfirmasi logout.
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
                Navigator.pop(context); // Menutup dialog.
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Navigasi ke halaman login.
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
        backgroundColor: Colors.pinkAccent, // Warna latar belakang AppBar.
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app), // Ikon logout.
            onPressed: _showLogoutConfirmation, // menampilkan dialog logout.
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildProductList() : _buildAddProductForm(), // Tampilkan halaman berdasarkan tab yang dipilih.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Index tab yang aktif.
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update index tab saat tap.
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Produk', // Label untuk tab produk.
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Tambah Produk', // Label untuk tab tambah produk.
          ),
        ],
      ),
    );
  }
}
