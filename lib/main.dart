import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pages/daftar_mahasiswa.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Mahasiswa',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const DaftarMahasiswaPage(), // Halaman utama adalah daftar mahasiswa
    );
  }
}

class FormMahasiswaPage extends StatefulWidget {
  const FormMahasiswaPage({super.key});

  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage> {
  // --- Form key & step
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0; // hanya 1 step (index 0)

  // --- Controller & field
  final cNama = TextEditingController();
  final cNpm = TextEditingController();
  final cEmail = TextEditingController();
  final cAlamat = TextEditingController();
  DateTime? tglLahir;
  TimeOfDay? jamBimbingan;

  String get tglLahirLabel =>
      tglLahir == null ? 'Pilih tanggal' : '${tglLahir!.day}/${tglLahir!.month}/${tglLahir!.year}';
  String get jamLabel =>
      jamBimbingan == null ? 'Pilih jam' : jamBimbingan!.format(context);

  @override
  void dispose() {
    cNama.dispose();
    cNpm.dispose();
    cEmail.dispose();
    cAlamat.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 1),
      initialDate: DateTime(now.year - 18, now.month, now.day),
    );
    if (res != null) setState(() => tglLahir = res);
  }

  Future<void> _pickTime() async {
    final res = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (res != null) setState(() => jamBimbingan = res);
  }

  // URL API - sesuaikan dengan server PHP Anda
  // Untuk Laragon: http://api.test:8080/tambah_mhs.php
  static const String apiUrl = 'http://api.test:8080/tambah_mhs.php';

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Periksa kembali isian Anda.')),
      );
      return;
    }
    if (tglLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal lahir belum dipilih')),
      );
      return;
    }
    if (jamBimbingan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jam bimbingan belum dipilih')),
      );
      return;
    }

    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Menyimpan data...'),
          ],
        ),
      ),
    );

    try {
      final data = {
        'nama': cNama.text.trim(),
        'npm': cNpm.text.trim(),
        'email': cEmail.text.trim(),
        'alamat': cAlamat.text.trim(),
        'tglLahir': tglLahirLabel,
        'jamBimbingan': jamLabel,
      };

      print('Mengirim data: ${json.encode(data)}'); // Debug log

      // Kirim data ke API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      // Tutup loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        // Cek apakah response body adalah JSON yang valid
        try {
          final responseData = json.decode(response.body);
          
          if (responseData['status'] == true) {
            // Berhasil disimpan
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Berhasil'),
                content: Text(responseData['message']),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _resetForm();
                      // Kembalikan true untuk menandakan data berhasil ditambah
                      Navigator.pop(context, true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            // Ada error dari API
            _showErrorDialog(responseData['message']);
          }
        } catch (jsonError) {
          // Response bukan JSON yang valid
          _showErrorDialog('Server mengembalikan response yang tidak valid:\n\n${response.body}');
        }
      } else {
        _showErrorDialog('Gagal menghubungi server. Status: ${response.statusCode}\n\nResponse: ${response.body}');
      }
    } catch (e) {
      // Tutup loading dialog jika masih ada
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorDialog('Terjadi kesalahan koneksi:\n\n$e\n\nPastikan:\n1. Server API sudah berjalan\n2. URL API benar: $apiUrl\n3. Koneksi internet tersedia');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    cNama.clear();
    cNpm.clear();
    cEmail.clear();
    cAlamat.clear();
    setState(() {
      tglLahir = null;
      jamBimbingan = null;
    });
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final steps = <Step>[
      Step(
        title: const Text('Identitas'),
        isActive: true,
        state: StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Data Pribadi'),
            TextFormField(
              controller: cNama,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'cth: Aulia Rahman',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: cNpm,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'NPM',
                hintText: 'cth: 221234567',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'NPM wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: cEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'cth: nama@kampus.ac.id',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                final ok =
                    RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
                return ok ? null : 'Format email tidak valid';
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: cAlamat,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cake_outlined),
                    label: Text(tglLahirLabel),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: Text(jamLabel),
                    onPressed: _pickTime,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Mahasiswa'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep, // selalu 0
          steps: steps,
          onStepContinue: _simpan,
          onStepCancel: null,
          controlsBuilder: (context, details) {
            return Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan ke Database'),
                  onPressed: _simpan,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
