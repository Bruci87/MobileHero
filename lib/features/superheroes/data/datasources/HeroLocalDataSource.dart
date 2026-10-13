import 'package:sqflite/sqflite.dart';
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';

class HeroLocalDataSource {
  final Database database;

  HeroLocalDataSource({required this.database});

  static Future<void> createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS superheroes (
        id INTEGER PRIMARY KEY,
        name TEXT,
        imageUrl TEXT,
        powerstats TEXT,
        isRecruiting INTEGER
      )
    ''');
  }

  Future<List<SuperheroModel>> getCachedHeroes() async {
    final List<Map<String, dynamic>> maps = await database.query('superheroes');
    return maps.map((map) => SuperheroModel.fromJson(map)).toList();
  }

  Future<void> cacheHeroes(List<SuperheroModel> heroes) async {
    final batch = database.batch();
    for (var hero in heroes) {
      batch.insert(
        'superheroes',
        hero.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateHero(SuperheroModel hero) async {
    await database.update(
      'superheroes',
      hero.toJson(),
      where: 'id = ?',
      whereArgs: [hero.id],
    );
  }
}