import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Judul Buku',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Pengarang',
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tahun Terbit',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Logic untuk menyimpan data buku
                },
                child: const Text('Simpan Buku'),
              ),
            ],
          ),
        ),
      )
    );
  }
}
