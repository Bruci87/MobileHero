import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';
import 'package:herobatlle/features/superheroes/presentation/widgets/SuperheroCard.dart';
import 'package:herobatlle/features/superheroes/presentation/bloc/SuperheroBloc.dart';
import 'package:herobatlle/features/catalog/pages/SuperheroDetailPage.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Catálogo de Agentes'),
        centerTitle: true,
      ),
      body: BlocBuilder<SuperheroBloc, SuperheroState>(
        builder: (context, state) {
          if (state is SuperheroLoading || state is SuperheroInitial) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          if (state is SuperheroError) {
            return Center(
              child: Text(
                'Erro: ${state.message}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final currentState = state;
          final List<SuperheroModel> heroes = (currentState is SuperheroLoaded)
              ? currentState.heroes.map((item) {
            if (item is SuperheroModel) return item;

            return SuperheroModel(
              id: item.id,
              name: item.name,
              imageUrl: item.imageUrl,
              powerstats: item.powerstats,
              isRecruiting: false,
            );
          }).toList().cast<SuperheroModel>()
              : [];

          if (heroes.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum agente encontrado.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: heroes.length,
            itemBuilder: (context, index) {
              final hero = heroes[index];

              return SuperheroCard(
                hero: hero,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuperheroDetailPage(hero: hero),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}