import 'package:flutter/material.dart';
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';

class SuperheroCard extends StatelessWidget {
  final SuperheroModel hero;
  final VoidCallback onTap;
  final Widget? trailing;

  const SuperheroCard({
    Key? key,
    required this.hero,
    required this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rarityColors = hero.rarityColors;
    final primaryRarityColor = hero.rarityColor;
    final isMistico = hero.rarityName == 'Místico';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: rarityColors,
          ),
          boxShadow: isMistico
              ? [
            BoxShadow(
              color: primaryRarityColor.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ]
              : null,
        ),
        child: Container(
          margin: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(13.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[800],
                backgroundImage: hero.imageUrl.isNotEmpty ? NetworkImage(hero.imageUrl) : null,
                child: hero.imageUrl.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Overall (OVR): ${hero.overallFormatted}',
                      style: TextStyle(
                        color: isMistico ? primaryRarityColor : Colors.amberAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: isMistico && rarityColors.length >= 3
                      ? LinearGradient(
                    colors: [
                      rarityColors[0].withOpacity(0.3),
                      rarityColors[1].withOpacity(0.3),
                      rarityColors[2].withOpacity(0.3),
                    ],
                  )
                      : null,
                  color: isMistico ? null : primaryRarityColor.withOpacity(0.2),
                  border: Border.all(
                    color: primaryRarityColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  hero.rarityName,
                  style: TextStyle(
                    color: isMistico ? Colors.white : primaryRarityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}