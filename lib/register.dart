import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final _roles = ['pegawai', 'admin'];
  final supabase = Supabase.instance.client;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final role = _roleController.text.trim().isEmpty ? _roles.first : _roleController.text.trim();
    setState(() => _isLoading = true);

    try {
      final existingUser = await supabase
          .from('user')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email sudah terdaftar!')));
      } else {
        final maxIdData = await supabase
            .from('user')
            .select('id')
            .order('id', ascending: false)
            .limit(1)
            .maybeSingle();

        int newId = (maxIdData != null && maxIdData['id'] != null)
            ? (maxIdData['id'] as int) + 1
            : 1;

        await supabase.from('user').insert({
          'id': newId,
          'email': email,
          'password': password,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi berhasil!')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registrasi gagal: $error')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUser(int id, String email, String password, String role) async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('user').update({
        'email': email,
        'password': password,
        'role': role,
      }).eq('id', id);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui!')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update gagal: $error')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(int id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin menghapus data ini?'),
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
      ),
    );

    if (confirmDelete == true) {
      await supabase.from('user').delete().eq('id', id);
      setState(() {});
    }
  }

  void _editUserDialog(BuildContext context, Map<String, dynamic> user) {
    _emailController.text = user['email'];
    _passwordController.text = user['password'];
    _roleController.text = user['role'];

    bool isEditPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit User'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: !isEditPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            isEditPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              isEditPasswordVisible = !isEditPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: _roleController.text.isEmpty ? _roles.first : _roleController.text,
                      items: _roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          _roleController.text = value ?? _roles.first;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Role'),
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
                      Navigator.pop(context); // Tutup dialog edit
                    }
                  },
                  child: Text('Batal', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateUser(user['id'], _emailController.text, _passwordController.text, _roleController.text);
                    Navigator.pop(context);
                  },
                  child: Text('Simpan', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(backgroundColor: Colors.pinkAccent),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    return await supabase.from('user').select();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min, // Menyesuaikan ukuran kolom
          children: [
            Icon(Icons.person_add, color: Colors.white), // Menambahkan ikon person_add
            const SizedBox(width: 8), // Jarak antara ikon dan teks
            const Text(
              'REGISTRASI',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), // Warna teks putih
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent, 
      ),
      body: Container(
        color: Colors.pink[50], 
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(  
              future: _fetchUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final users = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white, // White card color
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        title: Text(user['email'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password: ${user['password']}'),
                            Text('Role: ${user['role']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editUserDialog(context, user),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(user['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog(context);
        },
        backgroundColor: Colors.pinkAccent,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    _emailController.clear();
    _passwordController.clear();
    _roleController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Tambah User Baru'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email belum terisi';
                          }
                          // if (!value.contains('@gmail.com')) {
                          //   return 'Email wajib menggunakan @gmail.com';
                          // }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () => setDialogState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password wajib terisi';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _roles.first,
                        items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                        onChanged: (value) => setDialogState(() => _roleController.text = value ?? _roles.first),
                        decoration: InputDecoration(labelText: 'Role'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    bool cancelAdd = await showDialog(
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
                    if (cancelAdd == true) {
                      Navigator.pop(context); // Menutup dialog
                    }
                  },
                  child: Text('Batal', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _register();
                    }
                  },
                  child: Text('Tambah User', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
