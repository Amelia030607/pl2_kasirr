import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({Key? key}) : super(key: key);

  @override
  _PenjualanScreenState createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _penjualan = []; // Menyimpan data penjualan

  @override
  void initState() {
    super.initState();
    _fetchPenjualan(); // Mengambil data penjualan dari Supabase
  }

  // Mengambil data penjualan dari Supabase
  Future<void> _fetchPenjualan() async {
    try {
      final response = await _supabase
          .from('penjualan')
          .select('penjualanID, created_at, tanggalpenjua, totalharga, pelangganID');
      if (response != null && response is List) {
        setState(() {
          _penjualan = response
              .map((item) => {
                    'penjualanID': item['penjualanID'],
                    'created_at': item['created_at'],
                    'tanggalpenjua': item['tanggalpenjua'],
                    'totalharga': item['totalharga'],
                    'pelangganID': item['pelangganID'],
                  })
              .toList();
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data penjualan: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Penjualan'),
      ),
      body: _penjualan.isEmpty
          ? const Center(
              child: Text('Belum ada data penjualan'),
            )
          : ListView.builder(
              itemCount: _penjualan.length,
              itemBuilder: (context, index) {
                final penjualan = _penjualan[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      'ID Penjualan: ${penjualan['penjualanID']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal Penjualan: ${penjualan['tanggalpenjua']}'),
                        Text('Total Harga: Rp ${penjualan['totalharga']}'),
                        Text('ID Pelanggan: ${penjualan['pelangganID']}'),
                        Text('Dibuat pada: ${penjualan['created_at']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
