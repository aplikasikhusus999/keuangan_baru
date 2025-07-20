import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Import for image picking
import 'package:file_picker/file_picker.dart'; // Import for file picking
import 'dart:io'; // Untuk File

class AddDebitScreen extends StatefulWidget {
  const AddDebitScreen({super.key});

  @override
  State<AddDebitScreen> createState() => _AddDebitScreenState();
}

class _AddDebitScreenState extends State<AddDebitScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false; // Untuk indikator loading

  File? _pickedFile; // Untuk menyimpan file gambar/dokumen yang dipilih
  String? _pickedFileName; // Untuk menampilkan nama file yang dipilih

  // Dapatkan instance Supabase client
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedFile = File(pickedImage.path);
        _pickedFileName = pickedImage.name;
      });
    }
  }

  // Fungsi untuk mengambil gambar dari kamera
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _pickedFile = File(pickedImage.path);
        _pickedFileName = pickedImage.name;
      });
    }
  }

  // Fungsi untuk memilih dokumen (PDF, dll.)
  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'jpg',
        'jpeg',
        'png'
      ], // Jenis file yang diizinkan
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _pickedFileName = result.files.single.name;
      });
    }
  }

  // Fungsi untuk mengunggah file ke Supabase Storage
  Future<String?> _uploadFileToSupabase() async {
    if (_pickedFile == null) return null;

    try {
      final String fileName =
          '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}_${_pickedFileName}';
      final String path = await supabase.storage
          .from('transaction_proofs') // Ganti dengan nama bucket Anda
          .upload(fileName, _pickedFile!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false));

      // Dapatkan URL publik dari file yang diunggah
      final String publicUrl =
          supabase.storage.from('transaction_proofs').getPublicUrl(fileName);

      return publicUrl;
    } on StorageException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah bukti: ${e.message}')),
        );
      }
      print('Supabase Storage error: ${e.message}');
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Terjadi kesalahan saat mengunggah: ${e.toString()}')),
        );
      }
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> _saveDebit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Aktifkan loading
      });

      String? proofUrl;
      if (_pickedFile != null) {
        proofUrl = await _uploadFileToSupabase();
        if (proofUrl == null) {
          setState(() {
            _isLoading = false;
          });
          return; // Gagal mengunggah, jangan lanjutkan penyimpanan transaksi
        }
      }

      try {
        final double amount = double.parse(_amountController.text);
        final String description = _descriptionController.text;

        // Tanggal dan waktu transaksi otomatis menggunakan waktu saat ini
        final DateTime transactionDateTime = DateTime.now();

        // Simpan data ke Supabase
        await supabase.from('transactions').insert({
          'amount': amount,
          'description': description,
          'type': 'debit', // Jenis transaksi debit
          'transaction_date':
              transactionDateTime.toIso8601String(), // Format ISO 8601
          'proof_url': proofUrl, // Simpan URL bukti jika ada
        });

        // Tampilkan pesan sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi debit berhasil disimpan!')),
          );
          Navigator.pop(context,
              true); // Kembali ke layar sebelumnya dengan sinyal sukses
        }
      } on PostgrestException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan debit: ${e.message}')),
          );
        }
        print('Supabase error: ${e.message}');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
          );
        }
        print('Error: $e');
      } finally {
        setState(() {
          _isLoading = false; // Nonaktifkan loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi Debit'),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Debit (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Keterangan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Bagian untuk unggah bukti
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Unggah Bukti (Opsional):',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pickImageFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galeri'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _takePicture,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Kamera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickDocument,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Pilih Dokumen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  if (_pickedFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'File terpilih: $_pickedFileName',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed:
                    _isLoading ? null : _saveDebit, // Nonaktifkan saat loading
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isLoading ? 'Menyimpan...' : 'Simpan Debit',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
