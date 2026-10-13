import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';
import 'MissionRepository.dart';

enum MissionOutcome { success, failure, draw }

class CombatArenaPage extends StatefulWidget {
  final MissionRepository repository;
  final List<SuperheroModel> selectedSquad;

  const CombatArenaPage({
    Key? key,
    required this.repository,
    required this.selectedSquad,
  }) : super(key: key);

  @override
  State<CombatArenaPage> createState() => _CombatArenaPageState();
}

class _CombatArenaPageState extends State<CombatArenaPage> {
  bool isLoading = true;
  List<MissionRoundModel> rounds = [];
  int currentRoundIndex = 0;

  int victories = 0;
  int defeats = 0;
  int draws = 0;

  final List<int> usedHeroIds = [];
  List<SuperheroModel> victoriousHeroes = [];
  bool missionFinished = false;

  @override
  void initState() {
    super.initState();
    _initializeMission();
  }

  Future<void> _initializeMission() async {
    try {
      final generatedRounds = await widget.repository.generateMissionRounds(widget.selectedSquad);
      if (!mounted) return;
      setState(() {
        rounds = generatedRounds;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao inicializar arena: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _selectHeroForRound(SuperheroModel hero) {
    if (usedHeroIds.contains(hero.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${hero.name} já foi escalado para uma rodada nesta missão!'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final currentRound = rounds[currentRoundIndex];

    final playerVal = hero.powerstats[currentRound.targetStat] ?? 0;
    final enemyVal = currentRound.enemy.powerstats[currentRound.targetStat] ?? 0;

    MissionOutcome outcome;
    if (playerVal > enemyVal) {
      outcome = MissionOutcome.success;
      victories++;
      victoriousHeroes.add(hero);
    } else if (playerVal < enemyVal) {
      outcome = MissionOutcome.failure;
      defeats++;
    } else {
      outcome = MissionOutcome.draw;
      draws++;
    }

    setState(() {
      usedHeroIds.add(hero.id);
    });

    _showRoundResultDialog(currentRound, hero, outcome, enemyVal);
  }

  void _showRoundResultDialog(MissionRoundModel round, SuperheroModel hero, MissionOutcome outcome, int enemyVal) {
    String title;
    Color color;
    if (outcome == MissionOutcome.success) {
      title = '🎉 Sucesso na Rodada!';
      color = Colors.greenAccent;
    } else if (outcome == MissionOutcome.failure) {
      title = '❌ Falha na Rodada!';
      color = Colors.redAccent;
    } else {
      title = '🤝 Empate Tático!';
      color = Colors.amber;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Atributo Disputado: ${round.targetStatDisplayName}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Seu Agente (${hero.name}): ${hero.powerstats[round.targetStat] ?? 0}', style: const TextStyle(color: Colors.white)),
            Text('Inimigo (${round.enemy.name}): $enemyVal', style: const TextStyle(color: Colors.white70)),
            const Divider(color: Colors.white24, height: 20),
            Text('Placar Atual: $victories Vitórias | $defeats Derrotas | $draws Empates', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () async {
              Navigator.pop(dialogContext); // Fecha o diálogo da rodada

              if (currentRoundIndex < rounds.length - 1) {
                setState(() {
                  currentRoundIndex++;
                });
              } else {
                await _finalizeMission();
              }
            },
            child: const Text('Prosseguir', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizeMission() async {
    final isOverallSuccess = victories >= (rounds.length / 2).ceil();
    Map<String, dynamic>? buffResult;

    if (isOverallSuccess && victoriousHeroes.isNotEmpty) {
      try {
        buffResult = await widget.repository.applyVictoryBuff(victoriousHeroes);
      } catch (e) {
        print('Erro ao aplicar buff/XP no SQLite: $e');
      }
    }

    if (!mounted) return;

    setState(() {
      missionFinished = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _showFinalResultDialog(isOverallSuccess, buffResult);
    });
  }

  void _showFinalResultDialog(bool isOverallSuccess, Map<String, dynamic>? buffResult) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          isOverallSuccess ? '🎉 Vitória Tática na Crise!' : '❌ Missão Comprometida',
          style: TextStyle(
            color: isOverallSuccess ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confrontos Vencidos: $victories/${rounds.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Vitórias: $victories | Derrotas: $defeats | Empates: $draws', style: const TextStyle(color: Colors.white70)),
            if (buffResult != null) ...[
              const SizedBox(height: 12),
              Text(
                '🌟 ${buffResult['hero'].name} ganhou +${buffResult['gainedXp']} XP e +1 em ${buffResult['attribute'].toString().toUpperCase()}!',
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
              if (buffResult['leveledUp'] == true) ...[
                const SizedBox(height: 6),
                Text(
                  '🚀 SUBIU DE NÍVEL! Novo Nível: ${buffResult['newLevel']}',
                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Navigator.pop(dialogContext); // Fecha o diálogo
              Navigator.pop(context); // Retorna com segurança à central de missões
            },
            child: const Text('Continuar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(title: const Text('Arena de Combate Tático')),
        body: const Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (rounds.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(title: const Text('Arena de Combate Tático')),
        body: const Center(child: Text('Erro ao gerar rondas da crise.', style: TextStyle(color: Colors.white))),
      );
    }

    if (missionFinished) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(title: const Text('Relatório Final'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.military_tech, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              const Text('Operação Concluída!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Placar Final: $victories Vitórias / $defeats Derrotas', style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar à Central', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final currentRound = rounds[currentRoundIndex];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Etapa ${currentRoundIndex + 1} de ${rounds.length}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Apresentação do Desafio (Inimigo e Atributo em disputa)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: currentRound.enemy.imageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(currentRound.enemy.imageUrl)
                        : null,
                    child: currentRound.enemy.imageUrl.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️ Alvo Hostil Detectado', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          currentRound.enemy.name,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Text(
                            'Atributo em Disputa: ${currentRound.targetStatDisplayName}',
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Escalação: Selecione 1 Agente',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Placar: $victories V | $defeats D',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Grid de Escalação (Bloqueia visualmente os agentes já utilizados na missão)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: widget.selectedSquad.length,
                itemBuilder: (context, index) {
                  final hero = widget.selectedSquad[index];
                  final isUsed = usedHeroIds.contains(hero.id);

                  return GestureDetector(
                    onTap: isUsed ? null : () => _selectHeroForRound(hero),
                    child: Opacity(
                      opacity: isUsed ? 0.35 : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUsed ? Colors.grey : hero.rarityColor,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.grey[800],
                                  backgroundImage: hero.imageUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(hero.imageUrl)
                                      : null,
                                  child: hero.imageUrl.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                                ),
                                if (isUsed)
                                  const Icon(Icons.check_circle, color: Colors.amber, size: 28),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              hero.name,
                              style: TextStyle(
                                color: isUsed ? Colors.grey : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isUsed ? 'USADO' : 'OVR ${hero.overallFormatted}',
                              style: TextStyle(
                                color: isUsed ? Colors.grey : hero.rarityColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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