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
  String errorMessage = '';

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
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan saat mengambil data pelanggan: $e';
      });
    }
  }

  Future<void> _addPelanggan(String nama, String alamat, String nomorTelepon, BuildContext context, VoidCallback refreshState) async {
    try {
      final existingPelangganResponse = await supabase
          .from('pelanggan')
          .select('nama_pelanggan')
          .eq('nama_pelanggan', nama)
          .maybeSingle();

      if (existingPelangganResponse != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pelanggan dengan nama ini sudah terdaftar!'), backgroundColor: Colors.black),
        );
        return;
      }

      final response = await supabase.from('pelanggan').insert({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
      }).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          pelanggan.add(response.first);
          errorMessage = '';
        });
        refreshState();
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal menambahkan pelanggan: $e';
      });
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
      setState(() {
        errorMessage = 'Gagal mengedit pelanggan: $e';
      });
    }
  }

  Future<void> _deletePelanggan(int id) async {
    try {
      final response = await supabase.from('pelanggan').delete().eq('pelangganID', id).select();
      if (response != null && response.isNotEmpty) {
        setState(() {
          pelanggan.removeWhere((item) => item['pelangganID'] == id);
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal menghapus pelanggan: $e';
      });
    }
  }

  void _showAddPelangganDialog({Map<String, dynamic>? pelangganData}) {
    final TextEditingController namaController = TextEditingController(
        text: pelangganData != null ? pelangganData['nama_pelanggan'] : '');
    final TextEditingController alamatController = TextEditingController(
        text: pelangganData != null ? pelangganData['alamat'] : '');
    final TextEditingController nomorTeleponController = TextEditingController(
        text: pelangganData != null ? pelangganData['nomor_telepon'] : '');

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    bool cancelEdit = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Konfirmasi Batal'),
                        content: Text('Apakah Anda yakin ingin membatalkan ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Tidak', style: TextStyle(color: Colors.white)),
                              style: TextButton.styleFrom(backgroundColor: Colors.red),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Ya', style: TextStyle(color: Colors.white)),
                              style: TextButton.styleFrom(backgroundColor: Colors.pinkAccent),
                          ),
                        ],
                      ),
                    );
                    if (cancelEdit == true) {
                      Navigator.pop(context); 
                    }
                  },
                  child: Text('Batal', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final String nama = namaController.text;
                      final String alamat = alamatController.text;
                      final String nomorTelepon = nomorTeleponController.text;

                      if (pelangganData == null) {
                        _addPelanggan(nama, alamat, nomorTelepon, context, () {
                          setDialogState(() {});
                        });
                      } else {
                        _editPelanggan(pelangganData['pelangganID'], nama, alamat, nomorTelepon);
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tidak', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(backgroundColor: Colors.red),
            ),
            ElevatedButton(
              onPressed: () {
                _deletePelanggan(id);
                Navigator.of(context).pop();
              },
              child: const Text('Ya', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
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
            Icon(Icons.account_circle, color: Colors.white), // Menambahkan ikon person
            const SizedBox(width: 8), // Jarak antara ikon dan teks
            const Text(
              'PELANGGAN',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 90, 145), // Warna latar belakang AppBar
      ),
      backgroundColor: Color(0xFFFFE6EC),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pelanggan.isEmpty
              ? const Center(child: Text('Tidak ada pelanggan!'))
              : ListView.builder(
                  itemCount: pelanggan.length,
                  itemBuilder: (context, index) {
                    final item = pelanggan[index];
                    return Card(
                      color: Colors.white, 
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text('Nama: ${item['nama_pelanggan']}'),
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
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showAddPelangganDialog(pelangganData: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteConfirmationDialog(item['pelangganID']),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPelangganDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}
