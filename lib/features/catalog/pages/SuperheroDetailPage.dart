import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';

class SuperheroDetailPage extends StatelessWidget {
  final SuperheroModel hero;

  const SuperheroDetailPage({Key? key, required this.hero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rarityColor = hero.rarityColor;
    final overall = hero.overallFormatted;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(hero.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: rarityColor, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: hero.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: hero.imageUrl,
                    height: 280,
                    width: 220,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      height: 280,
                      width: 220,
                      color: Colors.grey[800],
                      child: const Icon(Icons.person, size: 90, color: Colors.white54),
                    ),
                  )
                      : Container(
                    height: 280,
                    width: 220,
                    color: Colors.grey[800],
                    child: const Icon(Icons.person, size: 90, color: Colors.white54),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              hero.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: rarityColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: rarityColor),
                  ),
                  child: Text(
                    '${hero.rarityName} • Overall: $overall',
                    style: TextStyle(color: rarityColor, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ATRIBUTOS DE PODER',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),

            ...hero.powerstats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      color: entry.value >= 90 ? Colors.amber : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}