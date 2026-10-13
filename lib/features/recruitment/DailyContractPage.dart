import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../superheroes/data/models/SuperheroModel.dart';
import 'RecruitmentRepository.dart';
import '../squad/SquadDetailPage.dart';

class DailyContractPage extends StatefulWidget {
  final RecruitmentRepository repository;

  const DailyContractPage({super.key, required this.repository});

  @override
  State<DailyContractPage> createState() => _DailyContractPageState();
}

class _DailyContractPageState extends State<DailyContractPage> {
  List<SuperheroModel> heroes = [];
  bool isLoading = true;
  bool canOpenDaily = true;
  bool canOpenTactical = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<bool> _canOpenDailyContract() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpenedDate = prefs.getString('last_daily_contract_date');
    if (lastOpenedDate == null) return true;

    final today = DateTime.now().toIso8601String().split('T')[0];
    return lastOpenedDate != today;
  }

  Future<void> _markDailyContractAsOpened() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('last_daily_contract_date', today);
  }

  Future<bool> _canOpenTacticalContract() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpenedDate = prefs.getString('last_tactical_contract_date');
    if (lastOpenedDate == null) return true;

    final today = DateTime.now().toIso8601String().split('T')[0];
    return lastOpenedDate != today;
  }

  Future<void> _markTacticalContractAsOpened() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('last_tactical_contract_date', today);
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    try {
      final loadedHeroes = await widget.repository.getLocalHeroes();
      final dailyAllowed = await _canOpenDailyContract();
      final tacticalAllowed = await _canOpenTacticalContract();

      if (!mounted) return;
      setState(() {
        heroes = loadedHeroes;
        canOpenDaily = dailyAllowed;
        canOpenTactical = tacticalAllowed;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleOpenPack(int packSize) async {
    setState(() => isLoading = true);

    try {
      if (heroes.isEmpty) {
        await widget.repository.loadInitialHeroesToDb();
        heroes = await widget.repository.getLocalHeroes();
      }

      final available = heroes.where((hero) => !hero.isRecruiting).toList();

      if (available.isEmpty) {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todos os heróis já foram recrutados!')),
        );
        return;
      }

      if (packSize == 1) {
        final allowed = await _canOpenDailyContract();
        if (!allowed) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
            canOpenDaily = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Já abriste o Contrato Diário hoje! Volta amanhã.')),
          );
          return;
        }
      } else if (packSize == 5) {
        final allowed = await _canOpenTacticalContract();
        if (!allowed) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
            canOpenTactical = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Já abriste o Pacote Tático de Elite hoje! Volta amanhã.')),
          );
          return;
        }
      }

      final pulledHeroes = await widget.repository.openPack(count: packSize);

      if (packSize == 1 && pulledHeroes.isNotEmpty) {
        await _markDailyContractAsOpened();
        canOpenDaily = false;
      } else if (packSize == 5 && pulledHeroes.isNotEmpty) {
        await _markTacticalContractAsOpened();
        canOpenTactical = false;
      }

      final updatedHeroes = await widget.repository.getLocalHeroes();
      if (!mounted) return;

      setState(() {
        heroes = updatedHeroes;
        isLoading = false;
      });

      if (pulledHeroes.isNotEmpty) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => PackTearAnimationDialog(
            pulledHeroes: pulledHeroes,
            repository: widget.repository,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir pacote: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recruitedHeroes = heroes.where((h) => h.isRecruiting).toList();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Contratos & Pacotes Táticos'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.style, size: 70, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'Convocação Tática de Agentes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Escolha um pacote e toque nele para rasgar e revelar suas cartas!',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canOpenDaily ? () => _handleOpenPack(1) : null,
                  icon: const Icon(Icons.card_membership),
                  label: Text(
                    canOpenDaily ? 'Contrato Diário (1 Carta)' : 'Contrato Diário já resgatado hoje ⏳',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canOpenDaily ? Colors.amber : Colors.grey[700],
                    foregroundColor: canOpenDaily ? Colors.black : Colors.white54,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canOpenTactical ? () => _handleOpenPack(5) : null,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    canOpenTactical ? 'Pacote Tático de Elite (5 Cartas)' : 'Pacote Tático já resgatado hoje ⏳',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canOpenTactical ? Colors.deepPurpleAccent : Colors.grey[700],
                    foregroundColor: canOpenTactical ? Colors.white : Colors.white54,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (recruitedHeroes.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Agentes Recrutados (${recruitedHeroes.length}):',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recruitedHeroes.length,
                  itemBuilder: (context, index) {
                    final hero = recruitedHeroes[index];
                    final rarity = hero.rarityName;
                    final color = hero.rarityColor;

                    return Card(
                      color: Colors.grey[850],
                      margin: const EdgeInsets.symmetric(vertical: 4),
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
                              placeholder: (context, url) => const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white),
                            ),
                          )
                              : const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          hero.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Poder: ${hero.powerstats['power'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          rarity,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SquadDetailPage(hero: hero),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PackTearAnimationDialog extends StatefulWidget {
  final List<SuperheroModel> pulledHeroes;
  final RecruitmentRepository repository;

  const PackTearAnimationDialog({
    super.key,
    required this.pulledHeroes,
    required this.repository,
  });

  @override
  State<PackTearAnimationDialog> createState() => _PackTearAnimationDialogState();
}

class _PackTearAnimationDialogState extends State<PackTearAnimationDialog> {
  bool isTornOpen = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: !isTornOpen
              ? GestureDetector(
            key: const ValueKey('closed_pack'),
            onTap: () {
              setState(() {
                isTornOpen = true;
              });
            },
            child: Container(
              width: 260,
              height: 380,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo, Colors.amber],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withAlpha(120),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.style, size: 70, color: Colors.amber),
                  const SizedBox(height: 20),
                  const Text(
                    'BOOSTER PACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.pulledHeroes.length} Agente(s) Oculto(s)',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      '👆 Toque para Rasgar!',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              : Container(
            key: const ValueKey('opened_pack'),
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉 CARTAS REVELADAS!',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.pulledHeroes.length,
                    itemBuilder: (context, index) {
                      final hero = widget.pulledHeroes[index];
                      final rarity = hero.rarityName;
                      final rarityColor = hero.rarityColor;

                      return Card(
                        color: Colors.grey[850],
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: rarityColor, width: 2),
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
                                placeholder: (context, url) => const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white),
                              ),
                            )
                                : const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            hero.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Poder: ${hero.powerstats['power'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Text(
                            rarity,
                            style: TextStyle(
                              color: rarityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Guardar na Equipa', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}