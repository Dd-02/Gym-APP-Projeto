import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class ApiButton extends StatelessWidget {
  final VoidCallback onDownloaded;
  final apiService = ApiService();
  final dbHelper = DatabaseHelper();

  ApiButton({super.key, required this.onDownloaded});

  @override
  Widget build(BuildContext context) {
    // Função para descarregar e armazenar exercícios na base de dados
    return ElevatedButton(
      child: const Text('Descarregar exercícios da API'),
      onPressed: () async {
        try {
          List<dynamic> exercises = await apiService.fetchExercises();
          List<Map<String, dynamic>> exerciseMaps = exercises.map((exercise) {
            return {
              'id': exercise['id'],
              'bodyPart': exercise['bodyPart'],
              'equipment': exercise['equipment'],
              'gifUrl': exercise['gifUrl'],
              'name': exercise['name'],
              'target': exercise['target'],
              'secondaryMuscles': exercise['secondaryMuscles'].join(','),
              'instructions': exercise['instructions'].join(','),
            };
          }).toList();
          await dbHelper.insertExercises(exerciseMaps);
          onDownloaded(); 
        // ignore: empty_catches
        } catch (e) {
        }
      },
    );
  }
}