import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({Key? key}) : super(key: key);

  @override
  _TransaksiScreenState createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _produk = [];
  List<Map<String, dynamic>> _keranjang = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

    Future<void> _fetchProducts() async {
    try {
      final response = await _supabase.from('produk').select() ?? [];
      if (response.isNotEmpty) {
        setState(() {
          _produk = List<Map<String, dynamic>>.from(response);
        });
      } else {
        throw Exception('Produk tidak ditemukan');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
    }
  }


  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _keranjang.add(product);
    });
  }

  double _calculateTotal() {
    return _keranjang.fold(0.0, (total, item) => total + item['harga']);
  }

  Future<void> _decreaseStock() async {
    try {
      for (var item in _keranjang) {
        final response = await _supabase
            .from('produk')
            .select('stok')
            .eq('id_produk', item['id_produk'])
            .maybeSingle();

        if (response != null && response['stok'] != null) {
          final currentStock = response['stok'] as int;
          final newStock = currentStock - 1;

          if (newStock >= 0) {
            await _supabase
                .from('produk')
                .update({'stok': newStock})
                .eq('id_produk', item['id_produk']);
          } else {
            throw Exception('Stok tidak cukup untuk produk ${item['namaproduk']}');
          }
        } else {
          throw Exception('Produk tidak ditemukan atau stok tidak tersedia');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengurangi stok: $e')),
      );
    }
  }

  Future<void> _recordTransaction() async {
    try {
      bool confirm = await _showConfirmationDialog();
      if (confirm) {
        final transactionData = _keranjang.map((item) {
          return {
            'id_produk': item['id_produk'],
            'harga': item['harga'],
            'jumlah': 1,
          };
        }).toList();

        await _supabase.from('transaksi').insert(transactionData);

        await _decreaseStock();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil!')),
        );
        setState(() {
          _keranjang.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencatat transaksi: $e')),
      );
    }
  }

  Future<bool> _showConfirmationDialog() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembayaran'),
          content: const Text('Apakah Anda yakin ingin melanjutkan transaksi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );

    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Transaksi Pembelian'),
      // ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _produk.length,
              itemBuilder: (context, index) {
                final product = _produk[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(product['namaproduk']),
                    subtitle: Text('Harga: ${product['harga']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => _addToCart(product),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Keranjang Belanja:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ..._keranjang.map((item) {
                  return ListTile(
                    title: Text(item['namaproduk']),
                    subtitle: Text('Harga: ${item['harga']}'),
                  );
                }).toList(),
                const SizedBox(height: 20),
                Text('Total: Rp ${_calculateTotal().toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
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
