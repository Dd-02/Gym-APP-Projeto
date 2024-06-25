import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = 'https://exercisedb.p.rapidapi.com/exercises';
  static const String apiKey = '9d4d0101eamsh47df0f5e3968fc9p19ece9jsne0ba9b389120'; 

  Future<List<dynamic>> fetchExercises() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load exercises');
    }
  }
}