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
    _fetchProducts();
    _fetchPelanggan();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await _supabase.from('produk').select();
      setState(() {
        _produk = List<Map<String, dynamic>>.from(response).map((product) {
          product['selectedQuantity'] = 1;
          return product;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
    }
  }

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

  void _addToCart(Map<String, dynamic> product, int quantity) {
    if (product['stok'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maaf, stok habis untuk produk: ${product['namaproduk']}')),
      );
      return;
    }
    setState(() {
      product['quantity'] = quantity;
      _keranjang.add(product);
    });
  }

  double _calculateTotal() {
    return _keranjang.fold(
        0.0, (sum, item) => sum + (item['harga'] * item['quantity']));
  }

  Future<void> _recordTransaction() async {
    if (_selectedPelangganID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih pelanggan terlebih dahulu')),
      );
      return;
    }

    try {
      final totalPrice = _calculateTotal();
      final penjualanData = {
        'tanggalpenjualan': DateTime.now().toIso8601String(),
        'totalharga': totalPrice,
        'pelangganID': _selectedPelangganID,
      };

      final responsePenjualan = await _supabase
          .from('penjualan')
          .insert(penjualanData)
          .select();

      if (responsePenjualan.isEmpty) {
        throw 'Gagal mencatat data penjualan';
      }

      final penjualanID = responsePenjualan[0]['penjualanID'];

      final detailTransaksi = _keranjang.map((item) {
        return {
          'penjualanID': penjualanID,
          'id_produk': item['id_produk'],
          'Jumlahproduk': item['quantity'],
          'Subtotal': item['harga'] * item['quantity'],
        };
      }).toList();

      await _supabase.from('detailpenjualan').insert(detailTransaksi);

      await _decreaseStock();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PenjualanScreen()),
      );

      setState(() {
        _keranjang.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencatat transaksi: $e')),
      );
    }
  }

  Future<void> _decreaseStock() async {
    for (var item in _keranjang) {
      try {
        final id_produk = item['id_produk'];
        final quantity = item['quantity'];

        await _supabase.from('produk').update({
          'stok': item['stok'] - quantity,
        }).eq('id_produk', id_produk);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengurangi stok untuk produk: ${item['namaproduk']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color headerColor = Color.fromARGB(255, 255, 255, 255); // Warna header utama
    final Color softPinkAccent = Colors.pink[50]!; // Warna latar belakang yang senada

    return Scaffold(
      body: Container(
        color: softPinkAccent,
        child: Column(
          children: [
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
                  fillColor: Colors.pink[50], // Latar belakang dropdown
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownColor: Colors.pink[100], // Warna dropdown
                isExpanded: true,
                items: _pelanggan.map((pelanggan) {
                  return DropdownMenuItem<int>(
                    value: pelanggan['pelangganID'],
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.pinkAccent), // Ikon pelanggan
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
                    _selectedPelangganID = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
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
                          Text('Harga: Rp ${product['harga']}', style: const TextStyle(color: Color.fromARGB(179, 0, 0, 0))),
                          Text('Stok: ${product['stok']}', style: const TextStyle(color: Color.fromARGB(179, 5, 5, 5))),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Color.fromARGB(255, 245, 127, 182)),
                                onPressed: product['selectedQuantity'] > 1
                                    ? () {
                                        setState(() {
                                          product['selectedQuantity']--;
                                        });
                                      }
                                    : null,
                              ),
                              Text('${product['selectedQuantity']}', style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                              IconButton(
                                icon: const Icon(Icons.add, color: Color.fromARGB(255, 245, 127, 182)),
                                onPressed: product['selectedQuantity'] < product['stok']
                                    ? () {
                                        setState(() {
                                          product['selectedQuantity']++;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.lightBlue),
                        onPressed: product['stok'] > 0
                            ? () => _addToCart(product, product['selectedQuantity'])
                            : null,
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
                  const Text(
                    'Keranjang Belanja:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ..._keranjang.map((item) {
                    return ListTile(
                      title: Text(item['namaproduk']),
                      subtitle: Text('Harga: Rp ${item['harga']} x ${item['quantity']}'),
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
                        backgroundColor: headerColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _keranjang.isEmpty ? null : _recordTransaction,
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
    );
  }
}
