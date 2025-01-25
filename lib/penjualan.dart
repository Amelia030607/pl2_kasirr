import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'transaksi.dart'; // Pastikan file transaksi.dart diimpor

class PenjualanScreen extends StatefulWidget {
  @override
  _PenjualanScreenState createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _penjualan = [];

  @override
  void initState() {
    super.initState();
    _fetchPenjualan();
  }

  Future<void> _fetchPenjualan() async {
    try {
      final response = await _supabase
          .from('penjualan')
          .select('*, pelanggan(pelangganID), detailpenjualan(*)')
          .order('created_at', ascending: false);

      setState(() {
        _penjualan = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data penjualan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.pink[200],
      //   title: const Text('Histori Penjualan', style: TextStyle(color: Colors.white)),
      //   centerTitle: true,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => TransaksiScreen()),
      //       ); // Navigasi ke halaman transaksi.dart
      //     },
      //   ),
      // ),
      body: Container(
        color: Colors.pink[50],
        child: _penjualan.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _penjualan.length,
                itemBuilder: (context, index) {
                  final penjualan = _penjualan[index];
                  final pelanggan = penjualan['pelanggan'];
                  final detailPenjualan = List<Map<String, dynamic>>.from(penjualan['detailpenjualan']);

                  return Card(
                    margin: const EdgeInsets.all(12.0),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      iconColor: Colors.pink[300],
                      collapsedIconColor: Colors.pink[300],
                      title: Text(
                        'ID Penjualan: ${penjualan['penjualanID']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal: ${penjualan['tanggalpenjualan']}', style: const TextStyle(fontSize: 14)),
                          Text('ID Pelanggan: ${pelanggan['pelangganID']}', style: const TextStyle(fontSize: 14)),
                          Text('Total Harga: Rp ${penjualan['totalharga'].toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14, color: Colors.pink)),
                        ],
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Detail Penjualan:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 16),
                          ),
                        ),
                        ...detailPenjualan.map((detail) {
                          return ListTile(
                            title: Text('Produk ID: ${detail['id_produk']}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Jumlah: ${detail['Jumlahproduk']}',
                                    style: const TextStyle(fontSize: 14)),
                                Text('Subtotal: Rp ${detail['Subtotal'].toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14, color: Colors.pink)),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
