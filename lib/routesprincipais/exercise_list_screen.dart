import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../widgets/api_button.dart';

class ExerciseListScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onExerciseSelected;

  const ExerciseListScreen({super.key, required this.onExerciseSelected});

  @override
  _ExerciseListScreenState createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final dbHelper = DatabaseHelper(); 

  Future<void> _showExerciseDialog({Map<String, dynamic>? exercise}) async {
    final idController = TextEditingController(text: exercise?['id']);
    final bodyPartController = TextEditingController(text: exercise?['bodyPart']);
    final equipmentController = TextEditingController(text: exercise?['equipment']);
    final gifUrlController = TextEditingController(text: exercise?['gifUrl']);
    final nameController = TextEditingController(text: exercise?['name']);
    final targetController = TextEditingController(text: exercise?['target']);
    final secondaryMusclesController = TextEditingController(text: exercise?['secondaryMuscles']);
    final instructionsController = TextEditingController(text: exercise?['instructions']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(exercise == null ? 'Adicionar exercício' : 'Editar exercício'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: 'Id'),
                ),
                TextField(
                  controller: bodyPartController,
                  decoration: const InputDecoration(labelText: 'Parte do corpo'),
                ),
                TextField(
                  controller: equipmentController,
                  decoration: const InputDecoration(labelText: 'Equipamento'),
                ),
                TextField(
                  controller: gifUrlController,
                  decoration: const InputDecoration(labelText: 'Imagem'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: targetController,
                  decoration: const InputDecoration(labelText: 'Alvo'),
                ),
                TextField(
                  controller: secondaryMusclesController,
                  decoration: const InputDecoration(labelText: 'Músculos secundários'),
                ),
                TextField(
                  controller: instructionsController,
                  decoration: const InputDecoration(labelText: 'Instruções'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                final newExercise = {
                  'id': idController.text,
                  'bodyPart': bodyPartController.text,
                  'equipment': equipmentController.text,
                  'gifUrl': gifUrlController.text,
                  'name': nameController.text,
                  'target': targetController.text,
                  'secondaryMuscles': secondaryMusclesController.text,
                  'instructions': instructionsController.text,
                };

                if (exercise == null) {
                  await dbHelper.insertExercise(newExercise);
                } else {
                  await dbHelper.updateExercise(newExercise);
                }

                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 238, 24, 24),
        title: const Text('GymFit - Exercícios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showExerciseDialog();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getExercises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os exercícios.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(child: Text('Nenhum exercício encontrado.')),
                ApiButton(
                  onDownloaded: () {
                    setState(() {});
                  },
                ),
              ],
            );
          } else {
            var exercises = snapshot.data!;
            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                var exercise = exercises[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: exercise['gifUrl'] != null
                        ? Image.network(
                            exercise['gifUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey,
                            child: const Icon(Icons.image, size: 30, color: Colors.white),
                          ),
                    title: Text(exercise['name']),
                    subtitle: Text(exercise['bodyPart']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showExerciseDialog(exercise: exercise);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await dbHelper.deleteExercise(exercise['id']);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      widget.onExerciseSelected(exercise);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}