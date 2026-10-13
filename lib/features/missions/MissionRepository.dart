import 'dart:convert';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';

class MissionRoundModel {
  final SuperheroModel enemy;
  final String targetStat;

  MissionRoundModel({
    required this.enemy,
    required this.targetStat,
  });

  String get targetStatDisplayName {
    switch (targetStat.toLowerCase()) {
      case 'intelligence':
        return 'Inteligência';
      case 'strength':
        return 'Força';
      case 'speed':
        return 'Velocidade';
      case 'durability':
        return 'Resistência';
      case 'power':
        return 'Poder';
      case 'combat':
        return 'Combate';
      default:
        return targetStat.toUpperCase();
    }
  }
}

class MissionRepository {
  final Database database;
  final Random _random = Random();

  MissionRepository({required this.database});

  static const List<String> attributes = [
    'intelligence',
    'strength',
    'speed',
    'durability',
    'power',
    'combat',
  ];

  Future<List<SuperheroModel>> getSquadHeroes() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'superheroes',
        where: 'isRecruiting = ?',
        whereArgs: [1],
      );
      return maps.map((map) => SuperheroModel.fromJson(map)).toList();
    } catch (e) {
      print('Erro ao carregar esquadrão: $e');
      return [];
    }
  }

  Future<List<SuperheroModel>> _getEnemyCandidates(List<int> squadIds) async {
    final List<Map<String, dynamic>> maps = await database.query('superheroes');
    final allHeroes = maps.map((map) => SuperheroModel.fromJson(map)).toList();
    return allHeroes.where((hero) => !squadIds.contains(hero.id)).toList();
  }

  Future<List<MissionRoundModel>> generateMissionRounds(List<SuperheroModel> squad) async {
    if (squad.length < 5) {
      throw Exception('O esquadrão precisa ter pelo menos 5 agentes para iniciar uma missão!');
    }

    final squadIds = squad.map((h) => h.id).toList();
    final enemyCandidates = await _getEnemyCandidates(squadIds);
    final totalRounds = _random.nextInt(3) + 3;

    List<MissionRoundModel> rounds = [];

    for (int i = 0; i < totalRounds; i++) {
      if (enemyCandidates.isEmpty) break;
      final attribute = attributes[_random.nextInt(attributes.length)];
      final enemy = enemyCandidates[_random.nextInt(enemyCandidates.length)];

      rounds.add(MissionRoundModel(
        enemy: enemy,
        targetStat: attribute,
      ));
    }

    return rounds;
  }

  Future<Map<String, dynamic>?> applyVictoryBuff(List<SuperheroModel> victoriousHeroes) async {
    if (victoriousHeroes.isEmpty) return null;

    final buffedHero = victoriousHeroes[_random.nextInt(victoriousHeroes.length)];
    final buffedAttribute = attributes[_random.nextInt(attributes.length)];

    final currentValue = buffedHero.powerstats[buffedAttribute] ?? 0;
    if (currentValue < 100) {
      buffedHero.powerstats[buffedAttribute] = (currentValue + 1).clamp(0, 100);
    }

    int gainedXp = 80 + _random.nextInt(41);
    int newXp = buffedHero.currentXp + gainedXp;
    int newLevel = buffedHero.level;
    bool leveledUp = false;

    int xpNeeded = newLevel * 500;
    if (newXp >= xpNeeded && buffedHero.canLevelUp) {
      newLevel++;
      newXp -= xpNeeded;
      leveledUp = true;
    }

    await database.update(
      'superheroes',
      {
        'powerstats': jsonEncode(buffedHero.powerstats),
        'level': newLevel,
        'currentXp': newXp,
      },
      where: 'id = ?',
      whereArgs: [buffedHero.id],
    );

    return {
      'hero': buffedHero,
      'attribute': buffedAttribute,
      'gainedXp': gainedXp,
      'newLevel': newLevel,
      'leveledUp': leveledUp,
    };
  }
}