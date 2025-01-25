import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'penjualan.dart'; 

class TransaksiScreen extends StatefulWidget {
  @override
  _TransaksiScreenState createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _produk = [];
  List<Map<String, dynamic>> _keranjang = [];
  List<Map<String, dynamic>> _pelanggan = [];
  int? _selectedPelangganID;

  @override
  void initState() {
    super.initState();
    _fetchProducts();  // Mengambil data produk
    _fetchPelanggan(); // Mengambil data pelanggan
  }

  // Fungsi untuk mengambil data produk
  Future<void> _fetchProducts() async {
    try {
      final response = await _supabase.from('produk').select();
      setState(() {
        _produk = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
    }
  }

  // Fungsi untuk mengambil data pelanggan
  Future<void> _fetchPelanggan() async {
    try {
      final response = await _supabase.from('pelanggan').select();
      setState(() {
        _pelanggan = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat pelanggan: $e')),
      );
    }
  }

  // Menambahkan produk ke keranjang belanja
  void _addToCart(Map<String, dynamic> product, int quantity) {
    setState(() {
      product['quantity'] = quantity;
      _keranjang.add(product);
    });
  }

  // Menghitung total harga transaksi
  double _calculateTotal() {
    return _keranjang.fold(0.0, (sum, item) => sum + (item['harga'] * item['quantity']));
  }

  // Fungsi untuk mencatat transaksi
  Future<void> _recordTransaction() async {
    if (_selectedPelangganID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih pelanggan terlebih dahulu')),
      );
      return;
    }

    try {
      final transactionData = _keranjang.map((item) {
        return {
          'id_produk': item['id_produk'],
          'harga': item['harga'],
          'totalharga': item['totalharga'],
          'pelangganID': _selectedPelangganID,
        };
      }).toList();

      // Menyimpan transaksi ke tabel transaksi
      final responseTransaksi = await _supabase.from('transaksi').insert(transactionData);
      if (responseTransaksi.error != null) {
        throw responseTransaksi.error!.message;
      }

      // Menyimpan penjualan ke tabel penjualan
      final totalPrice = _calculateTotal();
      final penjualanData = {
        'tanggalpenjualan': DateTime.now().toIso8601String(),
        'totalharga': totalPrice,
        'pelangganID': _selectedPelangganID,
      };
      final responsePenjualan = await _supabase.from('penjualan').insert(penjualanData);
      if (responsePenjualan.error != null) {
        throw responsePenjualan.error!.message;
      }

      // Mengurangi stok setelah transaksi
      await _decreaseStock();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil!')),
      );

      // Navigasi ke PenjualanScreen setelah transaksi selesai
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PenjualanScreen()),
      );

      setState(() {
        _keranjang.clear(); // Mengosongkan keranjang setelah transaksi
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencatat transaksi: $e')),
      );
    }
  }

  // Fungsi untuk mengurangi stok produk setelah transaksi
  Future<void> _decreaseStock() async {
    for (var item in _keranjang) {
      try {
        final id_produk = item['id_produk'];
        final quantity = item['quantity'];
        
        // Mengupdate stok produk dengan query biasa
        final response = await _supabase.from('produk').update({
          'stok': (item['stok'] - quantity),
        }).eq('id_produk', id_produk);

        if (response.error != null) {
          throw response.error!.message;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengurangi stok untuk produk: ${item['namaproduk']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          // Tombol icon untuk menuju riwayat penjualan
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PenjualanScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown untuk memilih pelanggan
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<int>(
              value: _selectedPelangganID,
              hint: const Text('Pilih Pelanggan'),
              isExpanded: true,
              items: _pelanggan.map((pelanggan) {
                return DropdownMenuItem<int>(
                  value: pelanggan['pelangganID'],
                  child: Text(pelanggan['nama_pelanggan']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPelangganID = value;
                });
              },
            ),
          ),
          // Daftar produk
          Expanded(
            child: ListView.builder(
              itemCount: _produk.length,
              itemBuilder: (context, index) {
                final product = _produk[index];
                int selectedQuantity = 1; // Jumlah default
                return Card(
                  child: ListTile(
                    title: Text(product['namaproduk']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Harga: Rp ${product['harga']}'),
                        Text('Stok: ${product['stok']}'),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: selectedQuantity > 1
                                  ? () {
                                      setState(() {
                                        selectedQuantity--;
                                      });
                                    }
                                  : null,
                            ),
                            Text('$selectedQuantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: selectedQuantity < product['stok']
                                  ? () {
                                      setState(() {
                                        selectedQuantity++;
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => _addToCart(product, selectedQuantity),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bagian keranjang belanja
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keranjang Belanja:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Menampilkan produk di keranjang
                ..._keranjang.map((item) {
                  return ListTile(
                    title: Text(item['namaproduk']),
                    subtitle: Text('Harga: Rp ${item['harga']} x ${item['totalharga']}'),
                  );
                }).toList(),
                const SizedBox(height: 20),
                // Total harga
                Text(
                  'Total: Rp ${_calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _keranjang.isEmpty ? null : _recordTransaction,
                  child: const Text('Proses Pembayaran'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
