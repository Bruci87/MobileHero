import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:herobatlle/features/catalog/pages/CatalogPage.dart';
import '../../recruitment/DailyContractPage.dart';
import '../../recruitment/RecruitmentRepository.dart';
import '../../squad/SquadPage.dart';
import '../../squad/SquadRepository.dart';
import '../../missions/MissionsHubPage.dart';
import '../../missions/MissionRepository.dart';

class HomePage extends StatelessWidget {
  final Database database;

  const HomePage({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SuperHero Tactical Management'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _HomeCard(
              title: 'Agentes',
              subtitle: 'Catálogo geral de heróis',
              icon: Icons.group,
              color: Colors.blueAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CatalogPage()),
                );
              },
            ),

            _HomeCard(
              title: 'Contrato Diário',
              subtitle: 'Recrutar novos heróis',
              icon: Icons.card_giftcard,
              color: Colors.amber,
              onTap: () {
                final repository = RecruitmentRepository(database: database);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DailyContractPage(repository: repository),
                  ),
                );
              },
            ),

            _HomeCard(
              title: 'Meu Esquadrão',
              subtitle: 'Agentes da equipa',
              icon: Icons.shield,
              color: Colors.green,
              onTap: () {
                final squadRepository = SquadRepository(database: database);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SquadPage(repository: squadRepository),
                  ),
                );
              },
            ),

            _HomeCard(
              title: 'Missões',
              subtitle: 'Central tática e combate',
              icon: Icons.flash_on,
              color: Colors.deepOrange,
              onTap: () {
                final missionRepository = MissionRepository(database: database);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MissionsHubPage(repository: missionRepository),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}