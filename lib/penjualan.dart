import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          .select('penjualanID, tanggalpenjualan, pelanggan(pelangganID), totalharga')
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

  Future<void> _hapusPenjualan(int penjualanID) async {
    try {
      await _supabase.from('penjualan').delete().eq('penjualanID', penjualanID);
      setState(() {
        _penjualan.removeWhere((penjualan) => penjualan['penjualanID'] == penjualanID);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Penjualan ID $penjualanID berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus penjualan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapusPenjualan(penjualan['penjualanID']),
                          ),
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
                              );
                            },
                            child: const Text('Lihat Detail'),
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

  DetailTransaksiScreen({required this.penjualanID});

  @override
  _DetailTransaksiScreenState createState() => _DetailTransaksiScreenState();
}

class _DetailTransaksiScreenState extends State<DetailTransaksiScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _detailPenjualan = [];

  @override
  void initState() {
    super.initState();
    _fetchDetailPenjualan();
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

  Future<void> _hapusDetail(int detailID) async {
    try {
      await _supabase.from('detailpenjualan').delete().eq('detailID', detailID);
      setState(() {
        _detailPenjualan.removeWhere((detail) => detail['detailID'] == detailID);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Detail ID $detailID berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus detail transaksi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text('Detail Transaksi: ${widget.penjualanID}'),
        centerTitle: true,
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                        onPressed: () => _hapusDetail(detail['detailID']),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
