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
          product['selectedQuantity'] = 0; // Menambahkan kuantitas produk yang dipilih mulai dari 0
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
    if (quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jumlah produk tidak bisa 0')),
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
      // Cek apakah pelanggan adalah 'Pelanggan Biasa' atau bukan
      if (_isPelangganMember && item['nama_pelanggan'] != 'Pelanggan Biasa') {
        harga *= 0.88; // Diskon 12% jika pelanggan adalah member, kecuali 'Pelanggan Biasa'
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

      // Menyimpan data penjualan
      final responsePenjualan = await _supabase
          .from('penjualan')
          .insert(penjualanData)
          .select();

      if (responsePenjualan.isEmpty) {
        throw 'Gagal mencatat data penjualan';
      }

      final penjualanID = responsePenjualan[0]['penjualanID'];

      // Menyimpan detail transaksi
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

      // Tampilkan struk pembelanjaan
      _showReceipt();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil! Pembayaran sudah diproses.')),
      );

      setState(() {
        _fetchProducts(); // Refresh produk setelah pembayaran
        _fetchPelanggan(); // Refresh pelanggan setelah pembayaran
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

  // Fungsi untuk menampilkan struk pembelanjaan
  void _showReceipt() {
    final pelanggan = _pelanggan.firstWhere((p) => p['pelangganID'] == _selectedPelangganID);
    final namaPelanggan = pelanggan['nama_pelanggan'];
    final tanggalTransaksi = DateTime.now().toIso8601String();
    final bool isMember = _isPelangganMember && namaPelanggan != 'Pelanggan Biasa';
    final String diskon = isMember ? '12%' : '0%';
    final double totalPembayaran = _calculateTotal();
    final double totalSetelahDiskon = isMember ? totalPembayaran * 0.88 : totalPembayaran;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFFF0F5), // Soft pink background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Center(
            child: Text(
              '🛒 Struk Pembelian 🛍️',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Pelanggan: $namaPelanggan', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Tanggal: ${tanggalTransaksi.substring(0, 10)}'),
                Divider(color: Colors.black54),
                ..._keranjang.map((item) {
                  final int totalHarga = item['harga'] * item['quantity'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama Produk: ${item['namaproduk']}', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Jumlah: ${item['quantity']}'),
                        Text('Harga per item: Rp ${item['harga']}'),
                        Text(
                          'Subtotal: Rp $totalHarga',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Divider(color: Colors.black26),
                      ],
                    ),
                  );
                }).toList(),
                Divider(thickness: 1.5, color: Colors.black54),
                Text('Diskon: $diskon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                Text(
                  'Total Pembayaran: Rp ${totalSetelahDiskon.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  _showConfirmationDialog(context); // Tampilkan konfirmasi sebelum menutup
                },
                child: Text('Tutup', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  // Konfirmasi sebelum menutup
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menutup struk ini?"),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(); // Batal, kembali ke struk
              },
              child: Text("Batal",  style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup konfirmasi
                Navigator.of(context).pop(); // Tutup struk
                _clearCart(); // Kosongkan keranjang setelah menutup struk
              },
              child: Text("Ya", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mengosongkan keranjang
  void _clearCart() {
    setState(() {
      _keranjang.clear(); // Kosongkan daftar keranjang
    });
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
              Icon(Icons.monetization_on, color: Colors.white),
              SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "TRANSAKSI ",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    TextSpan(
                      text: "PEMBELIAN",
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
                  dropdownColor: Color.fromARGB(255, 255, 255, 255),
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
                      _isPelangganMember = _pelanggan.any((pelanggan) => pelanggan['pelangganID'] == value && pelanggan['nama_pelanggan'] != 'Pelanggan Biasa');
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
                  TextEditingController _quantityController = TextEditingController(text: product['selectedQuantity'].toString());

                  return Card(
                    color: headerColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        product['namaproduk'],
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harga: Rp ${product['harga']}', style: const TextStyle(color: Colors.black87)),
                          Text('Stok: ${product['stok']}', style: const TextStyle(color: Colors.black87)),
                          if (_isPelangganMember && product['nama_pelanggan'] != 'Pelanggan Biasa') ...[
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
                                onPressed: product['selectedQuantity'] > 0
                                    ? () {
                                        setState(() {
                                          product['selectedQuantity']--;
                                          _quantityController.text = product['selectedQuantity'].toString(); // Update TextField
                                        });
                                      }
                                    : null,
                              ),
                              // TextField untuk input jumlah produk
                              SizedBox(
                                width: 38,
                                height: 38,
                                child: TextField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(border: OutlineInputBorder()),
                                  onChanged: (value) {
                                    // Memastikan input adalah angka dan valid
                                    int? newQuantity = int.tryParse(value);
                                    if (newQuantity != null &&
                                        newQuantity >= 0 &&
                                        newQuantity <= product['stok']) {
                                      setState(() {
                                        product['selectedQuantity'] = newQuantity;
                                      });
                                    } else {
                                      _quantityController.text = product['selectedQuantity'].toString(); // Reset input jika tidak valid
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.pinkAccent),
                                onPressed: product['selectedQuantity'] < product['stok']
                                    ? () {
                                        setState(() {
                                          product['selectedQuantity']++;
                                          _quantityController.text = product['selectedQuantity'].toString(); // Update TextField
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
                        subtitle: Text('Jumlah: ${item['quantity']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeFromCart(item),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 10),
                    Text(
                      'Total Pembayaran: Rp ${_calculateTotal().toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _recordTransaction,
                      child: const Text('Proses Pembayaran', style: TextStyle(color: Colors.white, fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
