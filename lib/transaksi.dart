import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransaksiScreen extends StatefulWidget {
  @override
  _TransaksiScreenState createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _produk = []; // Daftar produk yang tersedia
  List<Map<String, dynamic>> _keranjang = []; // Daftar produk yang dipilih oleh pelanggan
  List<Map<String, dynamic>> _pelanggan = []; // Daftar pelanggan yang terdaftar
  int? _selectedPelangganID; // ID pelanggan yang dipilih untuk transaksi
  bool _isPelangganMember = false; // Menandakan apakah pelanggan adalah member

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Memuat daftar produk
    _fetchPelanggan(); // Memuat daftar pelanggan
  }

  // Fungsi untuk mengambil data produk dari Supabase
  Future<void> _fetchProducts() async {
    try {
      final response = await _supabase.from('produk').select();
      setState(() {
        _produk = List<Map<String, dynamic>>.from(response).map((product) {
          product['selectedQuantity'] = 1; // Menambahkan kuantitas produk yang dipilih
          return product;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
    }
  }

  // Fungsi untuk mengambil data pelanggan dari Supabase
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

  // Fungsi untuk menambahkan produk ke keranjang belanja
  void _addToCart(Map<String, dynamic> product, int quantity) {
    if (product['stok'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok habis: ${product['namaproduk']}')),
      );
      return;
    }
    setState(() {
      product['quantity'] = quantity;
      _keranjang.add(product); // Menambahkan produk ke keranjang
    });
  }

  // Fungsi untuk menghapus produk dari keranjang belanja
  void _removeFromCart(Map<String, dynamic> product) {
    setState(() {
      _keranjang.remove(product); // Menghapus produk dari keranjang
    });
  }

  // Fungsi untuk menghitung total harga transaksi
  double _calculateTotal() {
    double total = _keranjang.fold(0.0, (sum, item) {
      double harga = item['harga'] * item['quantity']; // Menghitung subtotal untuk setiap item
      if (_isPelangganMember) {
        harga *= 0.88; // Diskon 12% jika pelanggan adalah member
      }
      return sum + harga; // Mengembalikan total harga
    });
    return total;
  }

  // Fungsi untuk mencatat transaksi setelah pembayaran berhasil
  Future<void> _recordTransaction() async {
    if (_selectedPelangganID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih pelanggan terlebih dahulu')),
      );
      return;
    }

    try {
      final totalPrice = _calculateTotal(); // Menghitung total harga
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

      await _supabase.from('detailpenjualan').insert(detailTransaksi); // Menyimpan detail transaksi
      await _decreaseStock(); // Mengurangi stok produk

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil! Pembayaran sudah diproses.')),
      );

      setState(() {
        _keranjang.clear(); // Mengosongkan keranjang belanja setelah transaksi selesai
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

        await _supabase.from('produk').update({
          'stok': item['stok'] - quantity, // Mengurangi stok berdasarkan jumlah yang dibeli
        }).eq('id_produk', id_produk);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengurangi stok: ${item['namaproduk']}')),
        );
      }
    }
  }

  // Fungsi untuk mendaftarkan pelanggan baru
  Future<void> _registerMember(String nama, String alamat, String nomorTelepon) async {
    // Cek apakah ada inputan yang kosong
    if (nama.isEmpty || alamat.isEmpty || nomorTelepon.isEmpty) {
      // Tampilkan pesan jika ada input yang kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi!')),
      );
      return; // Menghentikan eksekusi jika ada field yang kosong
    }

    try {
      await _supabase.from('pelanggan').insert({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Tampilkan pesan sukses setelah data berhasil disimpan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi pelanggan berhasil!')),
      );

      // Memuat ulang daftar pelanggan setelah registrasi
      _fetchPelanggan();
    } catch (e) {
      // Tampilkan pesan gagal jika terjadi error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal registrasi pelanggan: $e')),
      );
    }
  }

  // Fungsi untuk menampilkan dialog registrasi pelanggan
  void _showRegisterDialog() {
    // Controller untuk setiap inputan (nama, alamat, nomor telepon)
    final TextEditingController namaController = TextEditingController();
    final TextEditingController alamatController = TextEditingController();
    final TextEditingController teleponController = TextEditingController();

    // Menampilkan dialog untuk registrasi pelanggan baru
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.pink[50], 
        title: Text(
          'Registrasi Pelanggan Baru',
          style: TextStyle(color: Colors.pink[900]), 
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Memastikan kolom memiliki ukuran minimum
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: 'Nama', 
                labelStyle: TextStyle(color: Colors.pink[700]), 
                border: OutlineInputBorder(), // Border kotak untuk input
              ),
            ),
            SizedBox(height: 10), // Spasi antar input
            
            // Input untuk Alamat
            TextField(
              controller: alamatController,
              decoration: InputDecoration(
                labelText: 'Alamat', 
                labelStyle: TextStyle(color: Colors.pink[700]), 
                border: OutlineInputBorder(), 
              ),
            ),
            SizedBox(height: 10), 

            // Input untuk Nomor Telepon
            TextField(
              controller: teleponController,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon', 
                labelStyle: TextStyle(color: Colors.pink[700]), 
                border: OutlineInputBorder(), 
              ),
            ),
          ],
        ),
        actions: [
          // Tombol Batal
          TextButton(
            onPressed: () => Navigator.pop(context), // Menutup dialog saat tombol batal ditekan
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding tombol
              decoration: BoxDecoration(
                color: Colors.pink[200], 
                borderRadius: BorderRadius.circular(5), // Membuat sudut tombol membulat
              ),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.white), 
              ),
            ),
          ),
          // Tombol Simpan
          TextButton(
            onPressed: () {
              // Menyimpan data jika tombol Simpan ditekan
              _registerMember(namaController.text, alamatController.text, teleponController.text);
              Navigator.pop(context); // Menutup dialog setelah data disimpan
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), 
              decoration: BoxDecoration(
                color: Colors.pink[300], 
                borderRadius: BorderRadius.circular(5), // Membuat sudut tombol membulat
              ),
              child: Text(
                'Simpan',
                style: TextStyle(color: Colors.white), 
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color headerColor = const Color.fromARGB(255, 255, 255, 255);
    final Color softPinkAccent = Colors.pink[50]!;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people, color: Colors.white),
              SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "DAFTAR ",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    TextSpan(
                      text: "PELANGGAN",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 90, 145),
        actions: [
          Tooltip(
            message: "Daftar Pelanggan",
            child: IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: _showRegisterDialog, // Menampilkan dialog registrasi
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
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
                      _selectedPelangganID = value;
                      // Memeriksa apakah pelanggan adalah member
                      _isPelangganMember = _pelanggan.any((pelanggan) => pelanggan['pelangganID'] == value);
                    });
                  },
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                          if (_isPelangganMember) ...[
                            const SizedBox(height: 5),
                            Text(
                              'Anda Mendapat Potongan 12%',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.pinkAccent),
                                onPressed: product['selectedQuantity'] > 1
                                    ? () {
                                        setState(() {
                                          product['selectedQuantity']--;
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
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.blueAccent),
                        onPressed: product['stok'] > 0
                            ? () => _addToCart(product, product['selectedQuantity']) // Menambahkan produk ke keranjang
                            : null,
                      ),
                    ),
                  );
                },
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
                        onPressed: _keranjang.isEmpty ? null : _recordTransaction, // Menyelesaikan transaksi
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
