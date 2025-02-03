import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdukScreen extends StatefulWidget {
  @override
  _ProdukScreenState createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Fungsi untuk mengambil daftar produk dari tabel 'produk' di Supabase
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

  // Fungsi untuk menampilkan dialog edit produk
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
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_namaProdukController, 'Nama Produk'),
                const SizedBox(height: 10),
                _buildTextField(_hargaController, 'Harga', keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildTextField(_stokController, 'Stok', keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                bool confirmCancel = await _confirmCancel();
                if (confirmCancel) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _updateProduct(product['id_produk'], _namaProdukController.text,
                      _hargaController.text, _stokController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Perbarui Data', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk membangun textfield dengan validator
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 2, 2, 2)),
      ),
      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label harus diisi';
        }

        if (label == 'Harga' || label == 'Stok') {
          final parsedValue = label == 'Harga'
              ? double.tryParse(value)
              : int.tryParse(value);

          if (parsedValue == null) {
            return '$label tidak valid. Harus berupa angka!';
          }
        }
        return null;
      },
    );
  }

  // Fungsi untuk memperbarui data produk
  Future<void> _updateProduct(
      int productId, String namaProduk, String harga, String stok) async {
    final hargaParsed = double.tryParse(harga);
    final stokParsed = int.tryParse(stok);

    if (hargaParsed == null || stokParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi harga dan stok dengan benar!')),
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

  // Fungsi untuk menampilkan dialog tambah produk
  void _showAddProductDialog() {
    final TextEditingController _namaProdukController = TextEditingController();
    final TextEditingController _hargaController = TextEditingController();
    final TextEditingController _stokController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          title: const Text('Tambah Produk', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_namaProdukController, 'Nama Produk'),
                const SizedBox(height: 10),
                _buildTextField(_hargaController, 'Harga', keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildTextField(_stokController, 'Stok', keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                bool confirmCancel = await _confirmCancel();
                if (confirmCancel) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _addProduct(_namaProdukController.text, _hargaController.text, _stokController.text);
                }
              },
              child: const Text('Tambah Produk', style: TextStyle(color: Colors.white)),
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

    if (hargaParsed == null || stokParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi harga dan stok dengan benar!')),
      );
      return;
    }

    try {
      // Cek apakah produk sudah ada
      final existingProduct = await _supabase
          .from('produk')
          .select()
          .eq('namaproduk', namaProduk)
          .single();

      if (existingProduct != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk sudah terdaftar!')),
        );
        return; // Jangan lanjutkan jika produk sudah ada
      }

      // Menambahkan produk baru
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

  // Fungsi untuk menghapus produk dari database
    Future<void> _deleteProduct(int productId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Hapus',
            style: TextStyle(color: const Color.fromARGB(255, 3, 3, 3)),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus produk ini?',
            style: TextStyle(color: const Color.fromARGB(255, 12, 12, 12)),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Latar belakang hitam untuk dialog
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog tanpa menghapus
              },
              style: TextButton.styleFrom(
              backgroundColor : Colors.red, 
              ),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Menutup dialog setelah hapus
                try {
                  await _supabase.from('produk').delete().eq('id_produk', productId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produk berhasil dihapus!')),
                  );
                  setState(() {}); // Memperbarui tampilan
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus produk: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(
              backgroundColor : Colors.pinkAccent, 
              ),
              child: Text(
                'Hapus',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Konfirmasi sebelum menutup dialog
  Future<bool> _confirmCancel() async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi'),
              content: const Text('Apakah Anda yakin ingin membatalkan ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Ya', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(backgroundColor: Colors.pinkAccent),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Tidak', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            );
          },
        )) ??
        false;
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
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home, color: Colors.white),
              SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "DATA ",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    TextSpan(
                      text: "PRODUK",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 90, 145),
      ),
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
