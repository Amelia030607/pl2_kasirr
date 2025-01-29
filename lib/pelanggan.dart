import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganScreen extends StatefulWidget {
  const PelangganScreen({Key? key}) : super(key: key);

  @override
  State<PelangganScreen> createState() => _PelangganScreenState();
}

class _PelangganScreenState extends State<PelangganScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pelanggan = []; // Menyimpan daftar pelanggan
  bool isLoading = true; // Status loading data

  @override
  void initState() {
    super.initState();
    _fetchPelanggan(); // Memanggil fungsi untuk mengambil data pelanggan saat halaman dimuat
  }

  // Fungsi untuk mengambil data pelanggan dari tabel 'pelanggan' di Supabase
  Future<void> _fetchPelanggan() async {
    try {
      final response = await supabase.from('pelanggan').select();
      setState(() {
        pelanggan = List<Map<String, dynamic>>.from(response);
        isLoading = false; // Mengubah status loading setelah data berhasil diambil
      });
    } catch (e) {
      _showError('Terjadi kesalahan saat mengambil data pelanggan: $e'); // Menampilkan error jika gagal mengambil data
    }
  }

  // Fungsi untuk menambahkan pelanggan baru
  Future<void> _addPelanggan(String nama, String alamat, String nomorTelepon) async {
    try {
      final response = await supabase.from('pelanggan').insert({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
      }).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          pelanggan.add(response.first); // Menambahkan pelanggan baru ke dalam daftar
        });
      }
    } catch (e) {
      _showError('Gagal menambahkan pelanggan: $e'); // Menampilkan error jika gagal menambah pelanggan
    }
  }

  // Fungsi untuk mengedit data pelanggan
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
            pelanggan[index] = response.first; // Mengupdate data pelanggan yang diedit
          }
        });
      }
    } catch (e) {
      _showError('Gagal mengedit pelanggan: $e'); // Menampilkan error jika gagal mengedit pelanggan
    }
  }

  // Fungsi untuk menghapus pelanggan
  Future<void> _deletePelanggan(int id) async {
    try {
      await supabase.from('pelanggan').delete().eq('pelangganID', id); // Menghapus data pelanggan dari Supabase
      setState(() {
        pelanggan.removeWhere((item) => item['pelangganID'] == id); // Menghapus pelanggan dari daftar
      });
    } catch (e) {
      _showError('Gagal menghapus pelanggan: $e'); // Menampilkan error jika gagal menghapus pelanggan
    }
  }

  // Fungsi untuk menampilkan pesan error menggunakan SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)), // Menampilkan pesan error
    );
  }

  // Fungsi untuk menampilkan dialog tambah/edit pelanggan
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
                Navigator.of(context).pop(); // Menutup dialog tanpa menyimpan perubahan
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
                    _addPelanggan(nama, alamat, nomorTelepon); // Menambahkan pelanggan baru
                  } else {
                    _editPelanggan(pelangganData['pelangganID'], nama, alamat, nomorTelepon); // Mengedit pelanggan yang ada
                  }
                  Navigator.of(context).pop(); // Menutup dialog setelah penyimpanan
                } else {
                  _showError('Mohon isi semua data dengan benar.'); // Menampilkan error jika data tidak lengkap
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
      body: Container(
        color: Colors.pink[50],
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(), // Menampilkan indikator loading saat data sedang diambil
              )
            : pelanggan.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada pelanggan!', // Menampilkan pesan jika tidak ada pelanggan
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
                                onPressed: () => _showAddPelangganDialog(pelangganData: item), // Menampilkan dialog edit pelanggan
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _deletePelanggan(item['pelangganID']), // Menghapus pelanggan
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPelangganDialog(), // Menampilkan dialog tambah pelanggan
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
