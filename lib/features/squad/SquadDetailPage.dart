import 'package:flutter/material.dart';
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';

class SquadDetailPage extends StatelessWidget {
  final SuperheroModel hero;

  const SquadDetailPage({Key? key, required this.hero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rarity = hero.rarityName;
    final rarityColor = hero.rarityColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(hero.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hero.imageUrl.isNotEmpty
                    ? Image.network(
                  hero.imageUrl,
                  height: 250,
                  width: 200,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 250,
                  width: 200,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hero.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: rarityColor.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: rarityColor, width: 1.5),
              ),
              child: Text(
                'Classificação: $rarity',
                style: TextStyle(
                  color: rarityColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Atributos de Combate',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...hero.powerstats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}