import 'package:belajar_flutter/pages/daftar_buku.dart';
import 'package:belajar_flutter/pages/tambah_buku.dart';
import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  void _changeIndex(int index){
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navbar Example', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(),
          SearchPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.plus_one),
            label: 'Tambah Buku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_sharp),
            label: 'Daftar Buku',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _changeIndex,
        selectedItemColor: Colors.greenAccent,
      ),
    );
  }
}