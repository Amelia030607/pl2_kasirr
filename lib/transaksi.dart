// Mengimpor paket-paket yang diperlukan
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'penjualan.dart'; // Menyertakan file penjualan.dart untuk navigasi ke halaman penjualan

// Definisi kelas utama TransaksiScreen
class TransaksiScreen extends StatefulWidget {
  @override
  _TransaksiScreenState createState() => _TransaksiScreenState();
}

// State untuk TransaksiScreen
class _TransaksiScreenState extends State<TransaksiScreen> {
  // Inisialisasi Supabase client untuk komunikasi dengan database
  final SupabaseClient _supabase = Supabase.instance.client;

  // Variabel untuk menyimpan data produk, keranjang, dan pelanggan
  List<Map<String, dynamic>> _produk = [];
  List<Map<String, dynamic>> _keranjang = [];
  List<Map<String, dynamic>> _pelanggan = [];
  int? _selectedPelangganID; // Variabel untuk menyimpan ID pelanggan yang dipilih

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Memanggil fungsi untuk mengambil data produk
    _fetchPelanggan(); // Memanggil fungsi untuk mengambil data pelanggan
  }

  // Fungsi untuk mengambil data produk dari database Supabase
  Future<void> _fetchProducts() async {
    try {
      final response = await _supabase.from('produk').select(); // Query untuk mengambil semua data produk
      setState(() {
        _produk = List<Map<String, dynamic>>.from(response).map((product) {
          product['selectedQuantity'] = 1; // Menambahkan atribut quantity untuk produk
          return product;
        }).toList();
      });
    } catch (e) {
      // Menampilkan pesan kesalahan jika gagal mengambil data produk
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
    }
  }

  // Fungsi untuk mengambil data pelanggan dari database Supabase
  Future<void> _fetchPelanggan() async {
    try {
      final response = await _supabase.from('pelanggan').select(); // Query untuk mengambil data pelanggan
      setState(() {
        _pelanggan = List<Map<String, dynamic>>.from(response); // Menyimpan data pelanggan ke dalam variabel
      });
    } catch (e) {
      // Menampilkan pesan kesalahan jika gagal mengambil data pelanggan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat pelanggan: $e')),
      );
    }
  }

  // Fungsi untuk menambahkan produk ke keranjang
  void _addToCart(Map<String, dynamic> product, int quantity) {
    if (product['stok'] == 0) { // Mengecek jika stok produk habis
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maaf, stok habis untuk produk: ${product['namaproduk']}')),
      );
      return;
    }
    setState(() {
      product['quantity'] = quantity; // Menambahkan atribut quantity ke produk
      _keranjang.add(product); // Menambahkan produk ke dalam keranjang
    });
  }

  // Fungsi untuk menghapus produk dari keranjang
  void _removeFromCart(Map<String, dynamic> product) {
    setState(() {
      _keranjang.remove(product); // Menghapus produk dari keranjang
    });
  }

  // Fungsi untuk menghitung total harga dari produk di keranjang
  double _calculateTotal() {
    return _keranjang.fold(
        0.0, (sum, item) => sum + (item['harga'] * item['quantity']));
  }

  // Fungsi untuk mencatat transaksi ke dalam database
  Future<void> _recordTransaction() async {
    if (_selectedPelangganID == null) { // Mengecek apakah pelanggan telah dipilih
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih pelanggan terlebih dahulu')),
      );
      return;
    }

    try {
      final totalPrice = _calculateTotal(); // Menghitung total harga transaksi
      final penjualanData = {
        'tanggalpenjualan': DateTime.now().toIso8601String(), // Waktu transaksi
        'totalharga': totalPrice, // Total harga transaksi
        'pelangganID': _selectedPelangganID, // ID pelanggan yang melakukan transaksi
      };

      // Menyimpan data transaksi ke tabel "penjualan"
      final responsePenjualan = await _supabase
          .from('penjualan')
          .insert(penjualanData)
          .select();

      if (responsePenjualan.isEmpty) {
        throw 'Gagal mencatat data penjualan';
      }

      final penjualanID = responsePenjualan[0]['penjualanID']; // Mendapatkan ID transaksi

      // Menyimpan detail transaksi ke tabel "detailpenjualan"
      final detailTransaksi = _keranjang.map((item) {
        return {
          'penjualanID': penjualanID,
          'id_produk': item['id_produk'],
          'Jumlahproduk': item['quantity'],
          'Subtotal': item['harga'] * item['quantity'],
        };
      }).toList();

      await _supabase.from('detailpenjualan').insert(detailTransaksi);

      await _decreaseStock(); // Mengurangi stok produk

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil!')),
      );

      // Menavigasi ke halaman penjualan
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PenjualanScreen()),
      );

      setState(() {
        _keranjang.clear(); // Mengosongkan keranjang
      });
    } catch (e) {
      // Menampilkan pesan kesalahan jika transaksi gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencatat transaksi: $e')),
      );
    }
  }

  // Fungsi untuk mengurangi stok produk
  Future<void> _decreaseStock() async {
    for (var item in _keranjang) {
      try {
        final id_produk = item['id_produk'];
        final quantity = item['quantity'];

        await _supabase.from('produk').update({
          'stok': item['stok'] - quantity, // Mengurangi stok produk
        }).eq('id_produk', id_produk);
      } catch (e) {
        // Menampilkan pesan kesalahan jika stok gagal diperbarui
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengurangi stok untuk produk: ${item['namaproduk']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color headerColor = const Color.fromARGB(255, 255, 255, 255); // Warna latar header
    final Color softPinkAccent = Colors.pink[50]!; // Warna latar utama

    return Scaffold(
      body: SingleChildScrollView( // Membuat halaman dapat di-scroll
        child: Container(
          color: softPinkAccent,
          child: Column(
            children: [
              // Dropdown untuk memilih pelanggan
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<int>(
                  value: _selectedPelangganID,
                  hint: const Text(
                    'Pilih Pelanggan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.pink[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  dropdownColor: Colors.pink[100],
                  isExpanded: true,
                  items: _pelanggan.map((pelanggan) {
                    return DropdownMenuItem<int>(
                      value: pelanggan['pelangganID'],
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.pinkAccent),
                          const SizedBox(width: 10),
                          Text(
                            pelanggan['nama_pelanggan'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPelangganID = value; // Menyimpan ID pelanggan yang dipilih
                    });
                  },
                ),
              ),

              // List produk yang dapat dipilih
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // Menonaktifkan scroll pada ListView produk
                itemCount: _produk.length,
                itemBuilder: (context, index) {
                  final product = _produk[index];
                  return Card(
                    color: headerColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(product['namaproduk'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harga: Rp ${product['harga']}', style: const TextStyle(color: Colors.black87)),
                          Text('Stok: ${product['stok']}', style: const TextStyle(color: Colors.black87)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.pinkAccent),
                                onPressed: product['selectedQuantity'] > 1
                                    ? () {
                                        setState(() {
                                          product['selectedQuantity']--; // Mengurangi quantity produk
                                        });
                                      }
                                    : null,
                              ),
                              Text('${product['selectedQuantity']}', style: const TextStyle(color: Colors.black87)),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.pinkAccent),
                                onPressed: product['selectedQuantity'] < product['stok']
                                    ? () {
                                        setState(() {
                                          product['selectedQuantity']++; // Menambah quantity produk
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.blueAccent),
                        onPressed: product['stok'] > 0
                            ? () => _addToCart(product, product['selectedQuantity'])
                            : null, // Menambahkan produk ke keranjang jika stok tersedia
                      ),
                    ),
                  );
                },
              ),

              // Menampilkan keranjang belanja
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keranjang Belanja:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ..._keranjang.map((item) {
                      return ListTile(
                        title: Text(item['namaproduk']),
                        subtitle: Text('Harga: Rp ${item['harga']} x ${item['quantity']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeFromCart(item), // Menghapus produk dari keranjang
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    Text(
                      'Total: Rp ${_calculateTotal().toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _keranjang.isEmpty ? null : _recordTransaction, // Memproses transaksi jika keranjang tidak kosong
                        child: const Text(
                          'Proses Pembayaran',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
