import 'package:sqflite/sqflite.dart';
import '../superheroes/data/models/SuperheroModel.dart';

class SquadRepository {
  final Database database;

  SquadRepository({required this.database});

  Future<List<SuperheroModel>> getActiveSquad() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'superheroes',
      where: 'isRecruiting = ?',
      whereArgs: [1],
    );
    return maps.map((map) => SuperheroModel.fromJson(map)).toList();
  }

  Future<void> removeFromSquad(int heroId) async {
    await database.update(
      'superheroes',
      {'isRecruiting': 0},
      where: 'id = ?',
      whereArgs: [heroId],
    );
  }
}