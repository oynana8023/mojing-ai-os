import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;
  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mojing_studio_ultimate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(join(dbPath, filePath), version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const txt = 'TEXT NOT NULL';
    const txtN = 'TEXT';
    const intN = 'INTEGER';

    await db.execute('''CREATE TABLE projects (
      id $idType, title $txt, genre $txt, target_platform $txtN,
      market_plan $txtN, global_outline $txtN, status $txtN
    )''');

    await db.execute('''CREATE TABLE chapters (
      id $idType, project_id $intN, chapter_num $intN,
      title $txt, content $txtN,
      memory_state $txtN, qa_report $txtN, reader_score $txtN
    )''');

    await db.execute('''CREATE TABLE lore_entities (
      id $idType, project_id $intN, type $txt,
      name $txt, description $txtN, rules $txtN, status $txtN
    )''');

    await db.execute('''CREATE TABLE market_data (
      id $idType, project_id $intN, read_retention $txtN, comments $txtN, suggestions $txtN
    )''');

    await db.execute('CREATE TABLE providers (id TEXT PRIMARY KEY, type TEXT, api_key TEXT, models_json TEXT)');
    await db.execute('CREATE TABLE assignments (role_key TEXT PRIMARY KEY, provider_id TEXT, model_id TEXT)');
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(String table, String where, List<dynamic> args) async {
    final db = await instance.database;
    return await db.query(table, where: where, whereArgs: args);
  }

  Future<int> delete(String table, String column, dynamic id) async {
    final db = await instance.database;
    return await db.delete(table, where: '$column = ?', whereArgs: [id]);
  }

  Future<int> update(String table, Map<String, dynamic> row, String column, dynamic id) async {
    final db = await instance.database;
    return await db.update(table, row, where: '$column = ?', whereArgs: [id]);
  }
}