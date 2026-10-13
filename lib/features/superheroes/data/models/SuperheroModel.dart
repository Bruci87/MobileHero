import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class SuperheroModel extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final Map<String, int> powerstats;
  final bool isRecruiting;
  final int level;
  final int currentXp;
  final int baseLevel;

  const SuperheroModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.powerstats,
    this.isRecruiting = false,
    this.level = 1,
    this.currentXp = 0,
    int? baseLevel,
  }) : baseLevel = baseLevel ?? level;

  int get xpNeededForNextLevel => level * 500;

  bool get canLevelUp => (level - baseLevel) < 7 && level < 100;

  double get overallPower {
    if (powerstats.isEmpty) return 0.0;

    double totalWeightedScore = 0;
    int totalWeight = 0;

    powerstats.forEach((key, value) {
      int weight = 1;
      if (value >= 90) {
        weight = 3;
      } else if (value >= 70) {
        weight = 2;
      }

      totalWeightedScore += (value * weight);
      totalWeight += weight;
    });

    if (totalWeight == 0) return 0.0;
    return totalWeightedScore / totalWeight;
  }

  int get overallFormatted => overallPower.round().clamp(0, 100);

  String get rarityName {
    final double overall = overallPower;
    if (overall >= 90) return 'Místico';
    if (overall >= 80) return 'Lendário';
    if (overall >= 70) return 'Épico';
    if (overall >= 60) return 'Incomum';
    return 'Comum';
  }

  Color get rarityColor {
    switch (rarityName) {
      case 'Místico':
        return const Color(0xFF8B5CF6);
      case 'Lendário':
        return Colors.amber;
      case 'Épico':
        return Colors.deepPurple;
      case 'Incomum':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  List<Color> get rarityColors {
    switch (rarityName) {
      case 'Místico':
        return const [
          Color(0xFF8B5CF6),
          Color(0xFFEC4899),
          Color(0xFFF97316),
        ];
      case 'Lendário':
        return const [Colors.amber, Colors.amber];
      case 'Épico':
        return const [Colors.deepPurple, Colors.deepPurple];
      case 'Incomum':
        return const [Colors.blue, Colors.blue];
      default:
        return const [Colors.grey, Colors.grey];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'powerstats': jsonEncode(powerstats),
      'isRecruiting': isRecruiting ? 1 : 0,
      'level': level,
      'currentXp': currentXp,
      'baseLevel': baseLevel,
    };
  }

  factory SuperheroModel.fromJson(Map<String, dynamic> map) {
    Map<String, int> stats = {};

    try {
      if (map['powerstats'] is Map) {
        stats = Map<String, int>.from(map['powerstats']);
      } else if (map['powerstats'] is String) {
        final decoded = jsonDecode(map['powerstats']);
        if (decoded is Map) {
          stats = decoded.map((key, value) => MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0));
        }
      }
    } catch (_) {
      stats = {};
    }

    final parsedLevel = map['level'] is int ? map['level'] : int.tryParse(map['level']?.toString() ?? '') ?? 1;

    return SuperheroModel(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      name: map['name'] ?? 'Desconhecido',
      imageUrl: map['imageUrl'] ?? map['image_url'] ?? '',
      powerstats: stats,
      isRecruiting: map['isRecruiting'] == 1 || map['isRecruiting'] == true,
      level: parsedLevel,
      currentXp: map['currentXp'] is int ? map['currentXp'] : int.tryParse(map['currentXp']?.toString() ?? '') ?? 0,
      baseLevel: map['baseLevel'] is int ? map['baseLevel'] : parsedLevel,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, powerstats, isRecruiting, level, currentXp, baseLevel];
}