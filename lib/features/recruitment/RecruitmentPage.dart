import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../superheroes/data/models/SuperheroModel.dart';
class RecruitmentRepository {
  final Database database;

  RecruitmentRepository({required this.database});

  Future<List<SuperheroModel>> fetchRemoteHeroes() async {
    try {
      final response = await http.get(
        Uri.parse('https://akabab.github.io/superhero-api/api/all.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          final statsMap = json['powerstats'] as Map<String, dynamic>? ?? {};
          Map<String, int> formattedStats = {};
          statsMap.forEach((key, value) {
            formattedStats[key] =
            (value ?? 0) is int ? value : int.tryParse(value.toString()) ?? 0;
          });

          return SuperheroModel(
            id: json['id'],
            name: json['name'] ?? 'Desconhecido',
            imageUrl: json['images']?['lg'] ?? '',
            powerstats: formattedStats,
            isRecruiting: false,
          );
        }).toList();
      } else {
        throw Exception('Erro ao carregar heróis da API remota.');
      }
    } catch (e) {
      throw Exception('Falha de rede: $e');
    }
  }

  Future<List<SuperheroModel>> getLocalHeroes() async {
    final List<Map<String, dynamic>> maps = await database.query('superheroes');
    return maps.map((map) => SuperheroModel.fromJson(map)).toList();
  }

  Future<void> loadInitialHeroesToDb() async {
    final local = await getLocalHeroes();
    if (local.isEmpty) {
      final remoteHeroes = await fetchRemoteHeroes();
      for (var hero in remoteHeroes.take(100)) {
        await database.insert(
          'superheroes',
          hero.toJson(), // Utiliza toJson em vez de toMap
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<void> recruitHero(SuperheroModel hero) async {
    final updatedHero = SuperheroModel(
      id: hero.id ?? 0,
      name: hero.name,
      imageUrl: hero.imageUrl,
      powerstats: hero.powerstats,
      isRecruiting: true,
    );

    await database.update(
      'superheroes',
      updatedHero.toJson(),
      where: 'id = ?',
      whereArgs: [hero.id],
    );
  }

  String calculateRarity(SuperheroModel hero) {
    return hero.rarityName;
  }

  Future<bool> canOpenDailyContract() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpenedDate = prefs.getString('last_daily_contract_date');

    if (lastOpenedDate == null) return true;

    final today = DateTime.now().toIso8601String().split('T')[0];
    return lastOpenedDate != today;
  }

  Future<void> markDailyContractAsOpened() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('last_daily_contract_date', today);
  }

  Future<List<SuperheroModel>> openPack({required int count}) async {
    final allHeroes = await getLocalHeroes();
    final available = allHeroes.where((h) => !(h.isRecruiting)).toList();

    if (available.isEmpty) return [];

    final Random random = Random();
    List<SuperheroModel> pulledHeroes = [];

    for (int i = 0; i < count; i++) {
      if (available.isEmpty) break;

      int roll = random.nextInt(100);
      String targetTier;

      if (roll < 3) {
        targetTier = 'Lendário'; // 3%
      } else if (roll < 15) {
        targetTier = 'Místico';  // 12%
      } else if (roll < 45) {
        targetTier = 'Bom';      // 30%
      } else {
        targetTier = 'Comum';    // 55%
      }

      var tierHeroes = available.where((h) => calculateRarity(h) == targetTier).toList();

      if (tierHeroes.isEmpty) {
        tierHeroes = available;
      }

      tierHeroes.shuffle();
      final selected = tierHeroes.first;

      await recruitHero(selected);
      available.removeWhere((h) => h.id == selected.id);
      pulledHeroes.add(selected);
    }

    return pulledHeroes;
  }
}