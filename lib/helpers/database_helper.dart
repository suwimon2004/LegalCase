import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbName = 'cases.db';
  static const _dbVersion = 1;
  static const casesTable = 'cases';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $casesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        caseNumber TEXT NOT NULL,
        title TEXT NOT NULL,
        court TEXT,
        clientName TEXT,
        status TEXT,
        filingDate TEXT,
        nextHearingDate TEXT,
        summary TEXT,
        attachments TEXT
      )
    ''');
  }

  // Generic helpers (you can also make specific ones in provider)
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table,
      {String? orderBy}) async {
    final db = await database;
    return await db.query(table, orderBy: orderBy);
  }

  Future<int> update(String table, Map<String, dynamic> row, int id) async {
    final db = await database;
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
