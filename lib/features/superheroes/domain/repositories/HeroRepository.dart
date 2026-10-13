import 'package:herobatlle/features/superheroes/domain/entities/Superhero.dart';

abstract class HeroRepository {
  Future<List<Superhero>> getHeroes();
  Future<void> updateHero(Superhero hero);
}