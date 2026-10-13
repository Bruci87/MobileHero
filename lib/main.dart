import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'features/superheroes/data/datasources/HeroLocalDataSource.dart';
import 'features/superheroes/data/datasources/HeroRemoteDataSource.dart';
import 'features/superheroes/data/repositories/HeroRepositoryImpl.dart';
import 'features/superheroes/presentation/bloc/SuperheroBloc.dart';
import 'features/catalog/pages/HomePage.dart';
import 'features/recruitment/RecruitmentRepository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Database? database;
  try {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'superheroes_tactical.db');

    database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE superheroes (
            id INTEGER PRIMARY KEY,
            name TEXT,
            imageUrl TEXT,
            powerstats TEXT,
            isRecruiting INTEGER,
            level INTEGER DEFAULT 1,
            currentXp INTEGER DEFAULT 0,
            baseLevel INTEGER DEFAULT 1
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try { await db.execute("ALTER TABLE superheroes ADD COLUMN level INTEGER DEFAULT 1;"); } catch (_) {}
          try { await db.execute("ALTER TABLE superheroes ADD COLUMN currentXp INTEGER DEFAULT 0;"); } catch (_) {}
          try { await db.execute("ALTER TABLE superheroes ADD COLUMN baseLevel INTEGER DEFAULT 1;"); } catch (_) {}
        }
      },
    );

    final recruitmentRepository = RecruitmentRepository(database: database);
    await recruitmentRepository.loadInitialHeroesToDb();
  } catch (e) {
    print('⚠️ Erro crítico na inicialização do Banco de Dados: $e');
  }

  if (database == null) {
    print('❌ Falha fatal ao abrir o banco de dados SQLite.');
    return;
  }

  final localDataSource = HeroLocalDataSource(database: database);
  final remoteDataSource = HeroRemoteDataSource(client: http.Client());
  final heroRepositoryImpl = HeroRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  runApp(MyApp(
    heroRepository: heroRepositoryImpl,
    database: database,
  ));
}

class MyApp extends StatelessWidget {
  final HeroRepositoryImpl heroRepository;
  final Database database;

  const MyApp({super.key, required this.heroRepository, required this.database});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: heroRepository,
      child: BlocProvider(
        create: (context) => SuperheroBloc(repository: heroRepository)..add(LoadHeroesEvent()),
        child: MaterialApp(
          title: 'SuperHero Tactical Management',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          home: HomePage(database: database),
        ),
      ),
    );
  }
}