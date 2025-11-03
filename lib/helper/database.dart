import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      // Gunakan Directory.current.path seperti kode lama Anda
      String path = join(Directory.current.path, 'mahasiswa.db');

      print('Database path: $path');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createTable,
        onOpen: (db) {
          print('Database opened successfully');
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _createTable(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE mahasiswa (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          npm TEXT NOT NULL UNIQUE,
          email TEXT NOT NULL,
          alamat TEXT,
          tglLahir TEXT NOT NULL,
          jamBimbingan TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      print('Table mahasiswa created successfully');
    } catch (e) {
      print('Error creating table: $e');
      rethrow;
    }
  }

  Future<int> insertMahasiswa(Map<String, dynamic> mahasiswa) async {
    try {
      final db = await database;
      final result = await db.insert('mahasiswa', mahasiswa);
      print('Data inserted with id: $result');
      return result;
    } catch (e) {
      print('Error inserting mahasiswa: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllMahasiswa() async {
    try {
      final db = await database;
      final result = await db.query('mahasiswa', orderBy: 'created_at DESC');
      print('Retrieved ${result.length} records');
      return result;
    } catch (e) {
      print('Error getting all mahasiswa: $e');
      rethrow;
    }
  }

  Future<int> updateMahasiswa(int id, Map<String, dynamic> mahasiswa) async {
    try {
      final db = await database;
      return await db.update(
        'mahasiswa',
        mahasiswa,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error updating mahasiswa: $e');
      rethrow;
    }
  }

  Future<int> deleteMahasiswa(int id) async {
    try {
      final db = await database;
      return await db.delete('mahasiswa', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting mahasiswa: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getMahasiswaById(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        'mahasiswa',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting mahasiswa by id: $e');
      rethrow;
    }
  }

  Future<bool> isNpmExists(String npm, {int? excludeId}) async {
    try {
      final db = await database;
      String whereClause = 'npm = ?';
      List<dynamic> whereArgs = [npm];

      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }

      final result = await db.query(
        'mahasiswa',
        where: whereClause,
        whereArgs: whereArgs,
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking npm exists: $e');
      rethrow;
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
