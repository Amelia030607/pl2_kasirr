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
  String errorMessage = ''; // Menyimpan pesan error jika ada

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
        errorMessage = ''; // Menghapus pesan error jika data berhasil diambil
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan saat mengambil data pelanggan: $e'; // Menampilkan error jika gagal mengambil data
      });
    }
  }

  // Fungsi untuk menambahkan pelanggan baru dengan pengecekan nama yang duplikat
  Future<void> _addPelanggan(String nama, String alamat, String nomorTelepon) async {
    try {
      // Mengecek apakah nama pelanggan sudah ada
      final existingPelangganResponse = await supabase
          .from('pelanggan')
          .select('nama_pelanggan')
          .eq('nama_pelanggan', nama)
          .single(); // Mengambil satu baris data pelanggan dengan nama yang sama
    
      if (existingPelangganResponse != null) {
        // Menampilkan notifikasi jika nama pelanggan sudah ada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pelanggan dengan nama ini sudah terdaftar.')),
        );
        return; // Tidak melanjutkan proses penambahan jika nama sudah ada
      }

      // Jika nama pelanggan belum ada, lanjutkan untuk menambah pelanggan baru
      final response = await supabase.from('pelanggan').insert({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
      }).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          pelanggan.add(response.first); // Menambahkan pelanggan baru ke dalam daftar
          errorMessage = ''; // Menghapus pesan error jika berhasil
        });
        Navigator.of(context).pop(); // Menutup dialog setelah penyimpanan
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal menambahkan pelanggan: $e'; // Menampilkan error jika gagal menambah pelanggan
      });
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
      setState(() {
        errorMessage = 'Gagal mengedit pelanggan: $e'; // Menampilkan error jika gagal mengedit pelanggan
      });
    }
  }

  // Fungsi untuk menghapus pelanggan
    Future<void> _deletePelanggan(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Hapus Pelanggan',
            style: TextStyle(color: Color.fromARGB(255, 19, 19, 19)),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus pelanggan ini?',
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          ),
          backgroundColor: Color.fromARGB(255, 255, 255, 255), // Latar belakang hitam untuk dialog
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog tanpa menghapus
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.pinkAccent, // Tombol merah untuk hapus
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
                  await supabase.from('pelanggan').delete().eq('pelangganID', id); // Menghapus data pelanggan dari Supabase
                  setState(() {
                    pelanggan.removeWhere((item) => item['pelangganID'] == id); // Menghapus pelanggan dari daftar
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pelanggan berhasil dihapus!')),
                  );
                } catch (e) {
                  setState(() {
                    errorMessage = 'Gagal menghapus pelanggan: $e'; // Menampilkan error jika gagal menghapus pelanggan
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus pelanggan: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Tombol merah untuk hapus
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
    
    final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Key untuk Form

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          title: Text(
            pelangganData == null ? 'Tambah Pelanggan' : 'Edit Pelanggan',
            style: const TextStyle(color: Colors.pinkAccent),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: nomorTeleponController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon tidak boleh kosong';
                    }
                    final phoneRegExp = RegExp(r'^[0-9]+$');
                    if (!phoneRegExp.hasMatch(value)) {
                      return 'Nomor telepon hanya boleh angka';
                    }
                    return null;
                  },
                ),
                // Menampilkan pesan error jika ada
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
              ],
            ),
          ),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () {
                // Menampilkan dialog konfirmasi jika tombol batal ditekan
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text('Apakah Anda yakin ingin membatalkan ?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Menutup dialog konfirmasi
                            Navigator.of(context).pop(); // Menutup dialog utama
                          },
                          child: Text('Ya', style: TextStyle(color: Colors.white)),
                             style: TextButton.styleFrom(backgroundColor: Colors.pinkAccent),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Menutup dialog konfirmasi tanpa membatalkan
                          },
                          child: Text('Tidak', style: TextStyle(color: Colors.white)),
                             style: TextButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final String nama = namaController.text;
                  final String alamat = alamatController.text;
                  final String nomorTelepon = nomorTeleponController.text;

                  if (pelangganData == null) {
                    _addPelanggan(nama, alamat, nomorTelepon); // Menambahkan pelanggan baru
                  } else {
                    _editPelanggan(pelangganData['pelangganID'], nama, alamat, nomorTelepon); // Mengedit pelanggan yang ada
                  }
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min, // Menyesuaikan ukuran kolom
          children: [
            Icon(Icons.account_circle, color: Colors.white), // Menambahkan ikon
            const SizedBox(width: 8), // Jarak antara ikon dan teks
            const Text(
              'PELANGGAN',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), // Warna teks putih
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent, // Warna latar belakang AppBar
      ),
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
