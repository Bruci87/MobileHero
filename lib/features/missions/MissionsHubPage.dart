import 'package:flutter/material.dart';
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';
import 'MissionRepository.dart';
import 'MissionModel.dart';
import 'MissionsPage.dart';

class MissionsHubPage extends StatefulWidget {
  final MissionRepository repository;

  const MissionsHubPage({Key? key, required this.repository}) : super(key: key);

  @override
  State<MissionsHubPage> createState() => _MissionsHubPageState();
}

class _MissionsHubPageState extends State<MissionsHubPage> {
  bool isLoading = true;
  List<SuperheroModel> squadHeroes = [];

  final List<MissionModel> availableMissions = [
    const MissionModel(
      id: 'crisis_1',
      title: 'Invasão Alienígena Urbana',
      description: 'Uma nave-mãe inimiga posicionou-se sobre a cidade. O esquadrão precisa conter os avanços em múltiplos confrontos táticos.',
      requiredPower: 450,
      rewardXp: 1200,
      durationMinutes: 30,
    ),
    const MissionModel(
      id: 'crisis_2',
      title: 'Ataque Cibernético Global',
      description: 'Sistemas de defesa críticos foram comprometidos. Agentes com alta inteligência e combate são essenciais.',
      requiredPower: 500,
      rewardXp: 1500,
      durationMinutes: 45,
    ),
    const MissionModel(
      id: 'crisis_3',
      title: 'Revolta dos Vilões nas Instalações',
      description: 'Detentos super-poderosos escaparam simultaneamente. Contenha a rebelião em rondas sucessivas de pura força.',
      requiredPower: 600,
      rewardXp: 2000,
      durationMinutes: 60,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkSquadAndLoad();
  }

  Future<void> _checkSquadAndLoad() async {
    setState(() => isLoading = true);
    try {
      final heroes = await widget.repository.getSquadHeroes();
      setState(() {
        squadHeroes = heroes;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar esquadrão no Hub de Missões: $e');
      setState(() => isLoading = false);
    }
  }

  void _onTapMission(MissionModel mission) {
    // Regra: O esquadrão precisa ter pelo menos 5 agentes para iniciar uma Missão
    if (squadHeroes.length < 5) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Requisito Insuficiente', style: TextStyle(color: Colors.amber)),
          content: Text(
            'O esquadrão precisa ter pelo menos 5 agentes para iniciar uma Missão Tática.\n\nAtualmente tens apenas ${squadHeroes.length}/5 agentes no esquadrão.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido', style: TextStyle(color: Colors.amber)),
            ),
          ],
        ),
      );
      return;
    }

    // Se cumprir o requisito, avança para a seleção de agentes da missão
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MissionsPage(repository: widget.repository),
      ),
    ).then((_) => _checkSquadAndLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Central de Missões & Crises'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: squadHeroes.length >= 5 ? Colors.green.withAlpha(40) : Colors.red.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: squadHeroes.length >= 5 ? Colors.green : Colors.redAccent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prontidão do Esquadrão',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Agentes Recrutados: ${squadHeroes.length}/5 necessários',
                        style: TextStyle(
                          color: squadHeroes.length >= 5 ? Colors.greenAccent : Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    squadHeroes.length >= 5 ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: squadHeroes.length >= 5 ? Colors.greenAccent : Colors.redAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Crises Ativas no Sistema:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: availableMissions.length,
                itemBuilder: (context, index) {
                  final mission = availableMissions[index];
                  return Card(
                    color: Colors.grey[850],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.amber.withAlpha(100)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  mission.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.amber),
                                ),
                                child: Text(
                                  'XP +${mission.rewardXp}',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mission.description,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () => _onTapMission(mission),
                              child: const Text(
                                'Iniciar Operação de Crise',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}