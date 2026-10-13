import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String apiUrl = 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/all.json';

  Future<List<Map<String, dynamic>>> fetchSuperheroesFromApi() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((hero) {
        return {
          'id': hero['id'],
          'name': hero['name'] ?? 'Desconhecido',
          'slug': hero['slug'] ?? '',
          'intelligence': hero['powerstats']?['intelligence'] ?? 0,
          'strength': hero['powerstats']?['strength'] ?? 0,
          'speed': hero['powerstats']?['speed'] ?? 0,
          'durability': hero['powerstats']?['durability'] ?? 0,
          'power': hero['powerstats']?['power'] ?? 0,
          'combat': hero['powerstats']?['combat'] ?? 0,
          'fullName': hero['biography']?['fullName'] ?? '',
          'race': hero['appearance']?['race'] ?? 'Unknown',
          'gender': hero['appearance']?['gender'] ?? 'Unknown',
          'height': (hero['appearance']?['height'] as List?)?.isNotEmpty == true ? hero['appearance']['height'][1] : '',
          'weight': (hero['appearance']?['weight'] as List?)?.isNotEmpty == true ? hero['appearance']['weight'][1] : '',
          'eyeColor': hero['appearance']?['eyeColor'] ?? '',
          'hairColor': hero['appearance']?['hairColor'] ?? '',
          'work': hero['work']?['occupation'] ?? '',
          'base': hero['work']?['base'] ?? '',
          'imageTiny': hero['images']?['xs'] ?? '',
          'imageLarge': hero['images']?['lg'] ?? '',
        };
      }).toList();
    } else {
      throw Exception('Falha ao carregar dados da API do akabab');
    }
  }
}