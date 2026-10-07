import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;
  DBHelper._init();
  Future<Database> get database async { if (_database != null) return _database!; _database = await _initDB('mojing_final.db'); return _database!; }
  Future<Database> _initDB(String filePath) async { final dbPath = await getDatabasesPath(); return await openDatabase(join(dbPath, filePath), version: 1, onCreate: _createDB); }
  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE projects (id INTEGER PRIMARY KEY, title TEXT)');
  }
}