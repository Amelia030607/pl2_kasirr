import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdukScreen extends StatefulWidget {
  @override
  _ProdukScreenState createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .order('id_produk', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
      return [];
    }
  }

  void _showEditDialog(Map<String, dynamic> product) {
    final TextEditingController _namaProdukController =
        TextEditingController(text: product['namaproduk']);
    final TextEditingController _hargaController =
        TextEditingController(text: product['harga'].toString());
    final TextEditingController _stokController =
        TextEditingController(text: product['stok'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          title: const Text('Edit Produk', style: TextStyle(color: Colors.pinkAccent)),
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
                Navigator.pop(context);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              onPressed: () {
                _updateProduct(product['id_produk'], _namaProdukController.text,
                    _hargaController.text, _stokController.text);
                Navigator.pop(context);
              },
              child: const Text('Perbarui Data'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProduct(
      int productId, String namaProduk, String harga, String stok) async {
    final hargaParsed = double.tryParse(harga);
    final stokParsed = int.tryParse(stok);

    if (namaProduk.isEmpty || hargaParsed == null || stokParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data dengan benar!')),
      );
      return;
    }

    try {
      await _supabase.from('produk').update({
        'namaproduk': namaProduk,
        'harga': hargaParsed,
        'stok': stokParsed,
      }).eq('id_produk', productId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diperbarui!')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk: $e')),
      );
    }
  }

  void _showAddProductDialog() {
    final TextEditingController _namaProdukController = TextEditingController();
    final TextEditingController _hargaController = TextEditingController();
    final TextEditingController _stokController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          title: const Text('Tambah Produk', style: TextStyle(color: Colors.pinkAccent)),
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
                Navigator.pop(context);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              onPressed: () {
                _addProduct(_namaProdukController.text,
                    _hargaController.text, _stokController.text);
                Navigator.pop(context);
              },
              child: const Text('Tambah Produk'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addProduct(String namaProduk, String harga, String stok) async {
    final hargaParsed = double.tryParse(harga);
    final stokParsed = int.tryParse(stok);

    if (namaProduk.isEmpty || hargaParsed == null || stokParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua data dengan benar!')),
      );
      return;
    }

    try {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
        tooltip: 'Tambah Produk',
      ),
      // appBar: AppBar(
      //   backgroundColor: Colors.pinkAccent,
      //   title: const Text('Data Produk', style: TextStyle(color: Colors.white)),
      //   centerTitle: true,
      // ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada produk.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    product['namaproduk'],
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                  ),
                  subtitle: Text(
                      'Harga: ${product['harga']} | Stok: ${product['stok']}',
                      style: const TextStyle(color: Colors.black87)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          _showEditDialog(product);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await _deleteProduct(product['id_produk']);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
