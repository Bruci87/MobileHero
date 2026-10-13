import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:herobatlle/features/superheroes/domain/entities/Superhero.dart';
import 'package:herobatlle/features/superheroes/domain/repositories/HeroRepository.dart';

abstract class SuperheroEvent extends Equatable {
  const SuperheroEvent();
  @override
  List<Object?> get props => [];
}

class LoadHeroesEvent extends SuperheroEvent {}

class ToggleHeroRecruitmentEvent extends SuperheroEvent {
  final Superhero hero;
  const ToggleHeroRecruitmentEvent(this.hero);
  @override
  List<Object?> get props => [hero];
}

abstract class SuperheroState extends Equatable {
  const SuperheroState();
  @override
  List<Object?> get props => [];
}

class SuperheroInitial extends SuperheroState {}
class SuperheroLoading extends SuperheroState {}
class SuperheroLoaded extends SuperheroState {
  final List<Superhero> heroes;
  const SuperheroLoaded(this.heroes);
  @override
  List<Object?> get props => [heroes];
}
class SuperheroError extends SuperheroState {
  final String message;
  const SuperheroError(this.message);
  @override
  List<Object?> get props => [message];
}

class SuperheroBloc extends Bloc<SuperheroEvent, SuperheroState> {
  final HeroRepository repository;

  SuperheroBloc({required this.repository}) : super(SuperheroInitial()) {
    on<LoadHeroesEvent>(_onLoadHeroes);
    on<ToggleHeroRecruitmentEvent>(_onToggleHeroRecruitment);
  }

  Future<void> _onLoadHeroes(LoadHeroesEvent event, Emitter<SuperheroState> emit) async {
    emit(SuperheroLoading());
    try {
      final heroes = await repository.getHeroes();
      emit(SuperheroLoaded(heroes));
    } catch (e) {
      emit(SuperheroError(e.toString()));
    }
  }

  Future<void> _onToggleHeroRecruitment(ToggleHeroRecruitmentEvent event, Emitter<SuperheroState> emit) async {
    try {
      final updatedHero = Superhero(
        id: event.hero.id,
        name: event.hero.name,
        imageUrl: event.hero.imageUrl,
        powerstats: event.hero.powerstats,
        isRecruiting: !event.hero.isRecruiting,
      );

      await repository.updateHero(updatedHero);
      final heroes = await repository.getHeroes();
      emit(SuperheroLoaded(heroes));
    } catch (e) {
      emit(SuperheroError(e.toString()));
    }
  }
}