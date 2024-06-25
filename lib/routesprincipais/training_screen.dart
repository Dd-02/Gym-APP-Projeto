import 'package:flutter/material.dart';
import 'package:flutter_tarefa11/Login/autenticacao.dart';
import '../services/database_helper.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _workoutLists = [];
  List<Map<String, dynamic>> _exercises = [];
  int? _selectedListId;

  @override
  void initState() {
    super.initState();
    _initializeWorkoutLists();
  }

  Future<void> _initializeWorkoutLists() async {
    await dbHelper.ensureDefaultWorkoutList();
    await _loadWorkoutLists();
  }

  Future<void> _loadWorkoutLists() async {
    _workoutLists = await dbHelper.getWorkoutLists();
    if (_workoutLists.isNotEmpty && _selectedListId == null) {
      _selectedListId = _workoutLists.first['id'] as int?;
      await _loadExercises(_selectedListId!);
    }
    setState(() {});
  }

  Future<void> _loadExercises(int listId) async {
    try {
      _exercises = await dbHelper.getExercisesFromWorkoutList(listId);
    } catch (e) {
      _exercises = []; 
    }
    setState(() {});
  }

  Future<void> _addWorkoutList() async {
    TextEditingController controller = TextEditingController();
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar lista de treino'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nome da lista de treino'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (confirmed) {
      await dbHelper.insertWorkoutList(controller.text, []);
      await _loadWorkoutLists();
    }
  }

  Future<void> _renameWorkoutList(int listId) async {
    TextEditingController controller = TextEditingController();
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renomear lista de treino'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Novo nome da lista de treino'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Renomear'),
          ),
        ],
      ),
    );

    if (confirmed) {
      await dbHelper.renameWorkoutList(listId, controller.text);
      await _loadWorkoutLists();
    }
  }

  Future<void> _deleteWorkoutList(int listId) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar lista de treino'),
        content: const Text('Tem a certeza de que quer apagar esta lista de treino?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await dbHelper.deleteWorkoutList(listId);
              _selectedListId = null;
              await _loadWorkoutLists();
              Navigator.of(context).pop(true);
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {});
    }
  }

  Future<void> _deleteExerciseFromList(String exerciseId) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar exercício'),
        content: const Text('Tem a certeza de que deseja apagar este exercício da lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await dbHelper.deleteExerciseFromWorkoutList(_selectedListId!, exerciseId);
              await _loadExercises(_selectedListId!);
              Navigator.of(context).pop(true);
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {});
    }
  }

  Future<void> _showAddExerciseDialog() async {
    List<Map<String, dynamic>> allExercises = await dbHelper.getExercises();
    TextEditingController serieController = TextEditingController();
    TextEditingController repeticoesController = TextEditingController();
    TextEditingController kgController = TextEditingController();
    TextEditingController tempoEntreSeriesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar exercício'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              for (var exercise in allExercises)
                ListTile(
                  title: Text('Nome: ${exercise['name']}'),
                  subtitle: Text('Parte do corpo: ${exercise['bodyPart']}'),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Detalhes do exercício'),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              TextField(
                                controller: serieController,
                                decoration: const InputDecoration(labelText: 'Série'),
                                keyboardType: TextInputType.number,
                              ),
                              TextField(
                                controller: repeticoesController,
                                decoration: const InputDecoration(labelText: 'Repetições'),
                                keyboardType: TextInputType.number,
                              ),
                              TextField(
                                controller: kgController,
                                decoration: const InputDecoration(labelText: 'Kg'),
                                keyboardType: TextInputType.number,
                              ),
                              TextField(
                                controller: tempoEntreSeriesController,
                                decoration: const InputDecoration(labelText: 'Tempo entre séries (segundos)'),
                                keyboardType: TextInputType.number,
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
                            child: const Text('Adicionar'),
                            onPressed: () async {
                              int serie = int.parse(serieController.text);
                              int repeticoes = int.parse(repeticoesController.text);
                              double kg = double.parse(kgController.text);
                              int tempoEntreSeries = int.parse(tempoEntreSeriesController.text);

                              await dbHelper.addExerciseToWorkoutList(
                                _selectedListId!,
                                exercise['id'] as String,
                                serie,
                                repeticoes,
                                kg,
                                tempoEntreSeries,
                              );
                              Navigator.pop(context); 
                              Navigator.pop(context); 
                              await _loadExercises(_selectedListId!); 
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditExerciseDialog(Map<String, dynamic> exercise) async {
    TextEditingController serieController = TextEditingController(text: exercise['serie'].toString());
    TextEditingController repeticoesController = TextEditingController(text: exercise['repeticoes'].toString());
    TextEditingController kgController = TextEditingController(text: exercise['kg'].toString());
    TextEditingController tempoEntreSeriesController = TextEditingController(text: exercise['tempo_entre_series'].toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar exercício'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: serieController,
                decoration: const InputDecoration(labelText: 'Série'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: repeticoesController,
                decoration: const InputDecoration(labelText: 'Repetições'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: kgController,
                decoration: const InputDecoration(labelText: 'Kg'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: tempoEntreSeriesController,
                decoration: const InputDecoration(labelText: 'Tempo entre séries (segundos)'),
                keyboardType: TextInputType.number,
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
            child: const Text('Salvar'),
            onPressed: () async {
              int serie = int.tryParse(serieController.text) ?? 0;
              int repeticoes = int.tryParse(repeticoesController.text) ?? 0;
              double kg = double.tryParse(kgController.text) ?? 0.0;
              int tempoEntreSeries = int.tryParse(tempoEntreSeriesController.text) ?? 0;

              await dbHelper.updateExerciseInWorkoutList(
                _selectedListId!,
                exercise['id'] as String,
                serie,
                repeticoes,
                kg,
                tempoEntreSeries,
              );
              Navigator.pop(context); 
              await _loadExercises(_selectedListId!); 
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GymFit - Treino'),
        backgroundColor: Color.fromARGB(255, 238, 24, 24),
      ),
      drawer: Drawer(
          child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("SignOut"),
            onTap: () {
              Autenticacao().signout();
            },
          )
        ],
      )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    hint: const Text('Selecione uma lista de treino'),
                    value: _selectedListId,
                    items: _workoutLists.map((workoutList) {
                      return DropdownMenuItem<int>(
                        value: workoutList['id'] as int?,
                        child: Text(workoutList['name'] as String),
                      );
                    }).toList(),
                    onChanged: (int? newListId) async {
                      setState(() {
                        _selectedListId = newListId;
                      });
                      if (newListId != null) {
                        await _loadExercises(newListId);
                      }
                    },
                    isExpanded: true,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'add') {
                      _addWorkoutList();
                    } else if (value == 'rename' && _selectedListId != null) {
                      _renameWorkoutList(_selectedListId!);
                    } else if (value == 'delete' && _selectedListId != null) {
                      _deleteWorkoutList(_selectedListId!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'add',
                      child: Text('Adicionar lista'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'rename',
                      child: Text('Renomear lista'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Apagar lista'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _exercises.isEmpty
                ? const Center(
                    child: Text('Nenhum exercício encontrado'),
                  )
                : ListView.builder(
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      var exercise = _exercises[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: exercise['gifUrl'] != null && exercise['gifUrl'].isNotEmpty
                                    ? Image.network(
                                        exercise['gifUrl'] as String,
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
                              ),
                              title: Text(exercise['name'] as String),
                              subtitle: Text(exercise['bodyPart']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditExerciseDialog(exercise);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteExerciseFromList(exercise['id'] as String);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Séries: ${exercise['serie']} | Repetições: ${exercise['repeticoes']} | Kg: ${exercise['kg']} | Tempo entre séries: ${exercise['tempo_entre_series']}s',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: _showAddExerciseDialog,
              icon: const Icon(Icons.add),
              tooltip: 'Adicionar Exercício',
            ),
          ),
        ],
      ),
    );
  }
}