import 'package:herobatlle/features/superheroes/domain/entities/Superhero.dart';
import 'package:herobatlle/features/superheroes/domain/repositories/HeroRepository.dart';
import 'package:herobatlle/features/superheroes/data/datasources/HeroLocalDataSource.dart';
import 'package:herobatlle/features/superheroes/data/datasources/HeroRemoteDataSource.dart';
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';

class HeroRepositoryImpl implements HeroRepository {
  final HeroRemoteDataSource remoteDataSource;
  final HeroLocalDataSource localDataSource;

  HeroRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Superhero>> getHeroes() async {
    final localHeroes = await localDataSource.getCachedHeroes();

    return localHeroes.map((model) {
      // 🚀 Converte o Map<String, dynamic> para Map<String, int> com segurança
      final Map<String, int> convertedStats = {};
      model.powerstats.forEach((key, value) {
        convertedStats[key] = value is int ? value : int.tryParse(value?.toString() ?? '0') ?? 0;
      });

      return Superhero(
        id: model.id,
        name: model.name,
        imageUrl: model.imageUrl,
        powerstats: convertedStats,
        isRecruiting: model.isRecruiting,
      );
    }).toList();
  }

  @override
  Future<void> updateHero(Superhero hero) async {
    final superheroModel = SuperheroModel(
      id: hero.id,
      name: hero.name,
      imageUrl: hero.imageUrl,
      powerstats: hero.powerstats,
      isRecruiting: hero.isRecruiting,
    );

    await localDataSource.updateHero(superheroModel);
  }
}