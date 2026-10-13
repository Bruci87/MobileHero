import 'package:flutter/material.dart';

class Superhero {
  final int id;
  final String name;
  final String imageUrl;
  final Map<String, int> powerstats;
  final bool isRecruiting;

  const Superhero({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.powerstats,
    this.isRecruiting = false,
  });

  int get overallRating {
    if (powerstats.isEmpty) return 0;

    int totalScore = 0;
    int totalWeights = 0;

    powerstats.forEach((key, value) {
      int weight = 1;

      if (value >= 90) {
        weight = 3; // 90 para cima: peso 3
      } else if (value >= 70) {
        weight = 2; // 70 a 89: peso 2
      }

      totalScore += value * weight;
      totalWeights += weight;
    });

    if (totalWeights == 0) return 0;
    return (totalScore / totalWeights).round();
  }

  String get rarityName {
    final overall = overallRating;

    if (overall >= 90) return 'Místico';   // 90 a 100
    if (overall >= 80) return 'Lendário';  // 80 a 89
    if (overall >= 70) return 'Épico';     // 70 a 79
    if (overall >= 60) return 'Incomum';   // 60 a 69
    return 'Comum';                        // 59 para baixo
  }

  Color get rarityColor {
    switch (rarityName) {
      case 'Místico':
        return const Color(0xFFFF007F); // Magenta Neon (cor base de destaque)
      case 'Lendário':
        return const Color(0xFFFFD700); // Dourado
      case 'Épico':
        return const Color(0xFF9C27B0); // Roxo
      case 'Incomum':
        return const Color(0xFF4CAF50); // Verde
      default:
        return const Color(0xFF78909C); // Cinza / Comum
    }
  }

  LinearGradient? get rarityGradient {
    if (rarityName == 'Místico') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF), // 1. Branco
          Color(0xFFFF7A00), // 2. Laranja
          Color(0xFF6B21A8), // 3. Roxo
          Color(0xFFFF007F), // 4. Magenta
        ],
        stops: [0.0, 0.33, 0.66, 1.0],
      );
    }
    return null;
  }
}