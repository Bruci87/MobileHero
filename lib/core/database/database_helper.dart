import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('superhero_tactics.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE superheroes (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        slug TEXT,
        intelligence INTEGER,
        strength INTEGER,
        speed INTEGER,
        durability INTEGER,
        power INTEGER,
        combat INTEGER,
        fullName TEXT,
        race TEXT,
        gender TEXT,
        height TEXT,
        weight TEXT,
        eyeColor TEXT,
        hairColor TEXT,
        work TEXT,
        base TEXT,
        imageTiny TEXT,
        imageLarge TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE squad (
        heroId INTEGER PRIMARY KEY,
        recruitedAt TEXT,
        FOREIGN KEY (heroId) REFERENCES superheroes (id) ON DELETE CASCADE
      )
    ''');

    await createMissionTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await createMissionTable(db);
    }
  }

  static Future<void> createMissionTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS missions (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        requiredPower INTEGER,
        rewardXp INTEGER,
        durationMinutes INTEGER,
        isCompleted INTEGER,
        isInProgress INTEGER,
        startTimeMillis INTEGER
      )
    ''');
  }

  Future<void> cacheSuperheroes(List<Map<String, dynamic>> heroes) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var hero in heroes) {
      batch.insert(
        'superheroes',
        hero,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<bool> isCacheEmpty() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM superheroes'),
    );
    return count == 0;
  }
}