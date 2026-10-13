import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:herobatlle/features/superheroes/data/models/SuperheroModel.dart';

class HeroRemoteDataSource {
  final http.Client client;

  HeroRemoteDataSource({required this.client});

  Future<List<SuperheroModel>> fetchHeroes() async {
    final response = await client.get(
      Uri.parse('https://akabab.github.io/superhero-api/api/all.json'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) {
        final statsMap = json['powerstats'] as Map<String, dynamic>? ?? {};
        Map<String, int> formattedStats = {};
        statsMap.forEach((key, value) {
          formattedStats[key] = (value ?? 0) is int ? value : int.tryParse(value.toString()) ?? 0;
        });

        return SuperheroModel(
          id: json['id'],
          name: json['name'] ?? 'Desconhecido',
          imageUrl: json['images']?['lg'] ?? '',
          powerstats: formattedStats,
          isRecruiting: false,
        );
      }).toList();
    } else {
      throw Exception('Falha ao carregar heróis da API remota.');
    }
  }
}