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

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const txt = 'TEXT NOT NULL';
    const txtN = 'TEXT';
    const intN = 'INTEGER';

    // 1. 项目主表 (多开管理、一键立项)
    await db.execute('''CREATE TABLE projects (
      id $idType, title $txt, genre $txt, target_platform $txtN, 
      market_plan $txtN, global_outline $txtN, status $txtN
    )''');
    
    // 2. 章节创作表 (断点写作、超长记忆、审稿反馈)
    await db.execute('''CREATE TABLE chapters (
      id $idType, project_id $intN, chapter_num $intN,
      title $txt, content $txtN, 
      memory_state $txtN, qa_report $txtN, reader_score $txtN
    )''');

    // 3. 世界观与人物管理表 (角色性格、动机、伏笔链)
    await db.execute('''CREATE TABLE lore_entities (
      id $idType, project_id $intN, type $txt, /* CHARACTER, FACTION, ITEM, FORESHADOW */
      name $txt, description $txtN, rules $txtN, status $txtN
    )''');

    // 4. 商业数据回流表 (市场数据反馈)
    await db.execute('''CREATE TABLE market_data (
      id $idType, project_id $intN, read_retention $txtN, comments $txtN, suggestions $txtN
    )''');

    // 5. API 与 智能体排班表
    await db.execute('CREATE TABLE providers (id TEXT PRIMARY KEY, type TEXT, api_key TEXT, models_json TEXT)');
    await db.execute('CREATE TABLE assignments (role_key TEXT PRIMARY KEY, provider_id TEXT, model_id TEXT)');
  }

  // 通用 CRUD
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