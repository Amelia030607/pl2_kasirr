import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganScreen extends StatefulWidget {
  const PelangganScreen({Key? key}) : super(key: key);

  @override
  State<PelangganScreen> createState() => _PelangganScreenState();
}

class _PelangganScreenState extends State<PelangganScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pelanggan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPelanggan();
  }

  Future<void> _fetchPelanggan() async {
    try {
      final response = await supabase.from('pelanggan').select();
      setState(() {
        pelanggan = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      _showError('Terjadi kesalahan saat mengambil data pelanggan: $e');
    }
  }

  Future<void> _addPelanggan(String nama, String alamat, String nomorTelepon) async {
    try {
      final response = await supabase.from('pelanggan').insert({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
      }).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          pelanggan.add(response.first);
        });
      }
    } catch (e) {
      _showError('Gagal menambahkan pelanggan: $e');
    }
  }

  Future<void> _editPelanggan(int id, String nama, String alamat, String nomorTelepon) async {
    try {
      final response = await supabase.from('pelanggan').update({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
      }).eq('pelangganID', id).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          final index = pelanggan.indexWhere((item) => item['pelangganID'] == id);
          if (index != -1) {
            pelanggan[index] = response.first;
          }
        });
      }
    } catch (e) {
      _showError('Gagal mengedit pelanggan: $e');
    }
  }

  Future<void> _deletePelanggan(int id) async {
    try {
      await supabase.from('pelanggan').delete().eq('pelangganID', id);
      setState(() {
        pelanggan.removeWhere((item) => item['pelangganID'] == id);
      });
    } catch (e) {
      _showError('Gagal menghapus pelanggan: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAddPelangganDialog({Map<String, dynamic>? pelangganData}) {
    final TextEditingController namaController = TextEditingController(
        text: pelangganData != null ? pelangganData['nama_pelanggan'] : '');
    final TextEditingController alamatController = TextEditingController(
        text: pelangganData != null ? pelangganData['alamat'] : '');
    final TextEditingController nomorTeleponController = TextEditingController(
        text: pelangganData != null ? pelangganData['nomor_telepon'] : '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          title: Text(
            pelangganData == null ? 'Tambah Pelanggan' : 'Edit Pelanggan',
            style: const TextStyle(color: Colors.pinkAccent),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
              ),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: nomorTeleponController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              onPressed: () {
                final String nama = namaController.text;
                final String alamat = alamatController.text;
                final String nomorTelepon = nomorTeleponController.text;

                if (nama.isNotEmpty && alamat.isNotEmpty && nomorTelepon.isNotEmpty) {
                  if (pelangganData == null) {
                    _addPelanggan(nama, alamat, nomorTelepon);
                  } else {
                    _editPelanggan(pelangganData['pelangganID'], nama, alamat, nomorTelepon);
                  }
                  Navigator.of(context).pop();
                } else {
                  _showError('Mohon isi semua data dengan benar.');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Data Pelanggan', style: TextStyle(color: Colors.white)),
      //   backgroundColor: Colors.pinkAccent,
      //   centerTitle: true,
      // ),
      body: Container(
        color: Colors.pink[50],
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : pelanggan.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada pelanggan!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pelanggan.length,
                    itemBuilder: (context, index) {
                      final item = pelanggan[index];
                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            item['nama_pelanggan'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Alamat: ${item['alamat']}'),
                              Text('Nomor Telepon: ${item['nomor_telepon']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () => _showAddPelangganDialog(pelangganData: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _deletePelanggan(item['pelangganID']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPelangganDialog(),
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
