import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';
import 'MissionRepository.dart';
import 'CombatArenaPage.dart';

class MissionsPage extends StatefulWidget {
  final MissionRepository repository;

  const MissionsPage({Key? key, required this.repository}) : super(key: key);

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  List<SuperheroModel> squadHeroes = [];
  List<SuperheroModel> selectedHeroes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSquad();
  }

  Future<void> _loadSquad() async {
    setState(() => isLoading = true);
    try {
      final heroes = await widget.repository.getSquadHeroes();
      print('DEBUG - Heróis carregados para a missão: ${heroes.length}');
      setState(() {
        squadHeroes = heroes;
        isLoading = false;
      });
    } catch (e) {
      print('DEBUG - Erro ao carregar esquadrão: $e');
      setState(() => isLoading = false);
    }
  }

  void _toggleHeroSelection(SuperheroModel hero) {
    setState(() {
      if (selectedHeroes.contains(hero)) {
        selectedHeroes.remove(hero);
      } else {
        if (selectedHeroes.length < 15) {
          selectedHeroes.add(hero);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Podes selecionar no máximo 15 agentes para a missão!')),
          );
        }
      }
    });
  }

  void _startMission() {
    if (selectedHeroes.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleciona pelo menos 5 agentes para iniciar a operação!')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CombatArenaPage(
          repository: widget.repository,
          selectedSquad: selectedHeroes,
        ),
      ),
    ).then((_) {
      _loadSquad();
      setState(() {
        selectedHeroes.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Missões - Central Tática'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : squadHeroes.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'O teu esquadrão está vazio!',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tens de recrutar agentes primeiro nos Contratos Diários antes de poderes enviá-los para missões.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar para Recrutar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleciona os Agentes para a Missão (Mínimo 5):',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: squadHeroes.length,
                itemBuilder: (context, index) {
                  final hero = squadHeroes[index];
                  final isSelected = selectedHeroes.contains(hero);
                  final rarityColor = hero.rarityColor;

                  return Card(
                    color: isSelected ? Colors.deepPurple.withAlpha(100) : Colors.grey[850],
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? Colors.amber : rarityColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade800,
                        child: hero.imageUrl.isNotEmpty
                            ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: hero.imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white),
                          ),
                        )
                            : const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        hero.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Overall: ${hero.overallFormatted} (${hero.rarityName})',
                        style: TextStyle(color: rarityColor, fontWeight: FontWeight.w600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.amber),
                            ),
                            child: Text(
                              'OVR ${hero.overallFormatted}',
                              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: isSelected,
                            activeColor: Colors.amber,
                            onChanged: (_) => _toggleHeroSelection(hero),
                          ),
                        ],
                      ),
                      onTap: () => _toggleHeroSelection(hero),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: selectedHeroes.length >= 5 ? _startMission : null,
                icon: const Icon(Icons.flash_on),
                label: Text(
                  'Iniciar Missão (${selectedHeroes.length}/15 Agentes)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}