import 'package:flutter/material.dart';
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';
import 'package:herobatlle/features/superheroes/presentation/widgets/SuperheroCard.dart';
import 'SquadRepository.dart';
import 'SquadDetailPage.dart';

class SquadPage extends StatefulWidget {
  final SquadRepository repository;

  const SquadPage({Key? key, required this.repository}) : super(key: key);

  @override
  State<SquadPage> createState() => _SquadPageState();
}

class _SquadPageState extends State<SquadPage> {
  List<SuperheroModel> squadHeroes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSquad();
  }

  Future<void> _loadSquad() async {
    setState(() => isLoading = true);
    final heroes = await widget.repository.getActiveSquad();
    setState(() {
      squadHeroes = heroes;
      isLoading = false;
    });
  }

  Future<void> _removeHero(SuperheroModel hero) async {
    await widget.repository.removeFromSquad(hero.id);
    _loadSquad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('O Meu Esquadrão (${squadHeroes.length})'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : squadHeroes.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Ainda não tens nenhum herói no esquadrão.\nVai ao Contrato Diário ou Catálogo para recrutar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ),
      )
          : ListView.builder(
        itemCount: squadHeroes.length,
        itemBuilder: (context, index) {
          final hero = squadHeroes[index];

          return SuperheroCard(
            hero: hero,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SquadDetailPage(hero: hero),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _removeHero(hero),
            ),
          );
        },
      ),
    );
  }
}