import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';

class DaftarMahasiswaPage extends StatefulWidget {
  const DaftarMahasiswaPage({super.key});

  @override
  State<DaftarMahasiswaPage> createState() => _DaftarMahasiswaPageState();
}

class _DaftarMahasiswaPageState extends State<DaftarMahasiswaPage> {
  List<Map<String, dynamic>> mahasiswaList = [];
  bool isLoading = true;
  String errorMessage = '';

  static const String apiGetUrl = 'http://api.test:8080/get_mahasiswa.php';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(apiGetUrl));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == true) {
          setState(() {
            mahasiswaList = List<Map<String, dynamic>>.from(responseData['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = responseData['message'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Gagal menghubungi server. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _navigateToForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormMahasiswaPage(),
      ),
    );
    
    // Refresh data setelah kembali dari form
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Mahasiswa'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header dengan tombol tambah
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total: ${mahasiswaList.length} mahasiswa',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _navigateToForm,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Mahasiswa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Content area
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat data...'),
                      ],
                    ),
                  )
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red[600]),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : mahasiswaList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum Ada Data',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tambahkan data mahasiswa pertama',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _navigateToForm,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Tambah Mahasiswa'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildDataTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text(
                'No',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'NPM',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Nama',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Alamat',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Tanggal Lahir',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Jam Bimbingan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: mahasiswaList.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> mahasiswa = entry.value;
            
            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(mahasiswa['npm'] ?? '-')),
                DataCell(Text(mahasiswa['nama'] ?? '-')),
                DataCell(Text(mahasiswa['email'] ?? '-')),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      mahasiswa['alamat'] ?? '-',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(Text(mahasiswa['tglLahir'] ?? '-')),
                DataCell(Text(mahasiswa['jamBimbingan'] ?? '-')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
