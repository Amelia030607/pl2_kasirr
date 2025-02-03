import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'transaksi.dart';

class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({Key? key}) : super(key: key);

  @override
  _PenjualanScreenState createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _penjualan = [];

  @override
  void initState() {
    super.initState();
    _fetchPenjualan(); // Memanggil fungsi untuk mengambil data penjualan dari Supabase
  }

  // Fungsi untuk mengambil semua data penjualan dari Supabase
  Future<void> _fetchPenjualan() async {
    try {
      final response = await _supabase
          .from('penjualan')
          .select('penjualanID, tanggalpenjualan, pelanggan(pelangganID), totalharga')
          .order('created_at', ascending: false); // Mengurutkan berdasarkan waktu pembuatan

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
     appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, color: Colors.white),
              SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "RIWAYAT ",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    TextSpan(
                      text: "PENJUALAN",
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
      body: Container(
        color: Colors.pink[50],
        child: _penjualan.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _penjualan.length,
                itemBuilder: (context, index) {
                  final penjualan = _penjualan[index];
                  final pelanggan = penjualan['pelanggan'];

                  return Card(
                    margin: const EdgeInsets.all(12.0),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: ListTile(
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailTransaksiScreen(
                                    penjualanID: penjualan['penjualanID'],
                                  ),
                                ),
                              ).then((_) {
                                _fetchPenjualan(); // Menyegarkan data setelah kembali dari halaman DetailTransaksi
                              });
                            },
                            child: const Text('Lihat Detail',
                              style: TextStyle(
                                color: Colors.white, fontSize: 15
                              )
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool? confirmDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Hapus Penjualan'),
                                    content: const Text('Apakah Anda yakin ingin menghapus penjualan ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text('Batal', style: TextStyle(color: Colors.white)),
                                          style: TextButton.styleFrom(backgroundColor: Colors.red),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text('Hapus', style: TextStyle(color: Colors.white)),
                                          style: TextButton.styleFrom(backgroundColor: Colors.pinkAccent),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmDelete == true) {
                                try {
                                  await _supabase
                                      .from('penjualan')
                                      .delete()
                                      .eq('penjualanID', penjualan['penjualanID']);

                                  setState(() {
                                    _penjualan.removeAt(index);
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Penjualan berhasil dihapus')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal menghapus penjualan: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class DetailTransaksiScreen extends StatefulWidget {
  final int penjualanID;

  const DetailTransaksiScreen({required this.penjualanID});

  @override
  _DetailTransaksiScreenState createState() => _DetailTransaksiScreenState();
}

class _DetailTransaksiScreenState extends State<DetailTransaksiScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _detailPenjualan = [];

  @override
  void initState() {
    super.initState();
    _fetchDetailPenjualan(); // Memanggil fungsi untuk mengambil detail penjualan dari Supabase
  }

  Future<void> _fetchDetailPenjualan() async {
    try {
      final response = await _supabase
          .from('detailpenjualan')
          .select('detailID, penjualanID, id_produk, Jumlahproduk, Subtotal')
          .eq('penjualanID', widget.penjualanID);

      setState(() {
        _detailPenjualan = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail transaksi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(
          'Detail Transaksi: ${widget.penjualanID}',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: Container(
        color: Colors.pink[50],
        child: _detailPenjualan.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _detailPenjualan.length,
                itemBuilder: (context, index) {
                  final detail = _detailPenjualan[index];
                  return Card(
                    margin: const EdgeInsets.all(12.0),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        'Detail ID: ${detail['detailID']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Penjualan ID: ${detail['penjualanID']}', style: const TextStyle(fontSize: 14)),
                          Text('Produk ID: ${detail['id_produk']}', style: const TextStyle(fontSize: 14)),
                          Text('Jumlah: ${detail['Jumlahproduk']}', style: const TextStyle(fontSize: 14)),
                          Text('Subtotal: Rp ${detail['Subtotal'].toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14, color: Colors.pink)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          bool? confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Hapus Detail Transaksi'),
                                content: const Text('Apakah Anda yakin ingin menghapus detail transaksi ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('Batal', style: TextStyle(color: Colors.white)),
                                     style: TextButton.styleFrom(backgroundColor: Colors.red),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Hapus', style: TextStyle(color: Colors.white)),
                                      style: TextButton.styleFrom(backgroundColor: Colors.pinkAccent),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            try {
                              await _supabase
                                  .from('detailpenjualan')
                                  .delete()
                                  .eq('detailID', detail['detailID']);

                              setState(() {
                                _detailPenjualan.removeAt(index);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Detail transaksi berhasil dihapus')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal menghapus detail transaksi: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
