import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PenjualanScreen extends StatefulWidget {
  final String role; // Peran pengguna (admin, pegawai, pelanggan)

  const PenjualanScreen({required this.role});

  @override
  _PenjualanScreenState createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _penjualan = [];

  @override
  void initState() {
    super.initState();
    // Memuat data penjualan berdasarkan peran pengguna (admin, pegawai, pelanggan)
    if (widget.role == 'admin') {
      _fetchPenjualan();  // Untuk admin, menampilkan semua data penjualan
    } else {
      _fetchPenjualanForUser();  // Untuk pegawai dan pelanggan, hanya tampilkan data terkait pelanggan
    }
  }

  // Fungsi untuk mengambil data penjualan untuk admin
  Future<void> _fetchPenjualan() async {
    try {
      final response = await _supabase
          .from('penjualan')
          .select('penjualanID, tanggalpenjualan, pelanggan(pelangganID), totalharga')
          .order('created_at', ascending: false);  // Mengurutkan data berdasarkan waktu pembuatan

      setState(() {
        _penjualan = List<Map<String, dynamic>>.from(response);  // Menyimpan hasil ke dalam list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data penjualan: $e')),
      );
    }
  }

  // Fungsi untuk mengambil data penjualan untuk pegawai dan pelanggan
  Future<void> _fetchPenjualanForUser() async {
    try {
      // Untuk pegawai dan pelanggan, tampilkan transaksi berdasarkan pelangganID
      final response = await _supabase
          .from('penjualan')
          .select('penjualanID, tanggalpenjualan, pelanggan(pelangganID), totalharga')
          .eq('pelangganID', widget.role)  // Menggunakan role sebagai pelangganID
          .order('created_at', ascending: false);  // Mengurutkan berdasarkan tanggal transaksi

      setState(() {
        _penjualan = List<Map<String, dynamic>>.from(response);  // Menyimpan hasil ke dalam list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data penjualan: $e')),
      );
    }
  }

  // Fungsi untuk menghapus data penjualan, hanya bisa dilakukan oleh admin
  Future<void> _hapusPenjualan(int penjualanID) async {
    try {
      await _supabase.from('penjualan').delete().eq('penjualanID', penjualanID);
      setState(() {
        _penjualan.removeWhere((penjualan) => penjualan['penjualanID'] == penjualanID);  // Menghapus data dari list
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
    // Menampilkan halaman akses ditolak jika pengguna bukan admin
    if (widget.role != 'admin') {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: const Text('Akses Ditolak'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Anda tidak memiliki izin untuk mengakses halaman ini.',
            style: TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 90, 145),
        title: const Text(
          'Penjualan',
          style: TextStyle(
            fontSize: 24, 
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.pink[50],
        child: _penjualan.isEmpty
            ? const Center(child: CircularProgressIndicator())  // Menampilkan loading jika data belum dimuat
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
                      trailing: widget.role == 'admin'  // Menampilkan tombol hapus hanya untuk admin
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
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
                            )
                          : ElevatedButton(
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
    _fetchDetailPenjualan();  // Mengambil detail transaksi ketika layar dibuka
  }

  // Fungsi untuk mengambil detail penjualan berdasarkan penjualanID
  Future<void> _fetchDetailPenjualan() async {
    try {
      final response = await _supabase
          .from('detailpenjualan')
          .select('detailID, penjualanID, id_produk, Jumlahproduk, Subtotal')
          .eq('penjualanID', widget.penjualanID);  // Filter berdasarkan penjualanID

      setState(() {
        _detailPenjualan = List<Map<String, dynamic>>.from(response);  // Menyimpan data detail ke list
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
        title: Text('Detail Transaksi: ${widget.penjualanID}'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.pink[50],
        child: _detailPenjualan.isEmpty
            ? const Center(child: CircularProgressIndicator())  // Menampilkan loading jika data belum dimuat
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
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);  // Kembali ke halaman sebelumnya
        },
        child: const Icon(Icons.arrow_back),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}
