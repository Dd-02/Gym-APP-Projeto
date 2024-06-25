import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'gym_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE exercises(
        id TEXT PRIMARY KEY,
        bodyPart TEXT,
        equipment TEXT,
        gifUrl TEXT,
        name TEXT,
        target TEXT,
        secondaryMuscles TEXT,
        instructions TEXT
      )
      '''
    );

    await db.execute(
      '''
      CREATE TABLE workout_lists(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        exercises TEXT -- JSON string containing a list of exercise IDs
      )
      '''
    );

    await db.execute(
      '''
      CREATE TABLE workout_list_exercises(
        list_id INTEGER,
        exercise_id TEXT,
        serie INTEGER,
        repeticoes INTEGER,
        kg REAL,
        tempo_entre_series INTEGER,
        FOREIGN KEY (list_id) REFERENCES workout_lists(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
        PRIMARY KEY (list_id, exercise_id)
      )
      '''
    );
  }

  Future<void> insertExercises(List<Map<String, dynamic>> exercises) async {
    Database db = await database;
    Batch batch = db.batch();

    for (var exercise in exercises) {
      batch.insert('exercises', exercise, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<void> insertExercise(Map<String, dynamic> exercise) async {
    Database db = await database;
    await db.insert('exercises', exercise, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateExercise(Map<String, dynamic> exercise) async {
    Database db = await database;
    await db.update(
      'exercises',
      exercise,
      where: 'id = ?',
      whereArgs: [exercise['id']],
    );
  }

  Future<void> deleteExercise(String id) async {
    Database db = await database;
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getExercises() async {
    Database db = await database;
    return await db.query('exercises');
  }

  Future<void> insertWorkoutList(String name, List<String> exerciseIds) async {
    Database db = await database;
    await db.insert(
      'workout_lists',
      {
        'name': name,
        'exercises': json.encode(exerciseIds),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateWorkoutList(int id, List<String> exerciseIds) async {
    Database db = await database;
    await db.update(
      'workout_lists',
      {'exercises': json.encode(exerciseIds)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getExercisesFromWorkoutList(int listId) async {
    Database db = await database;
    var result = await db.query(
      'workout_list_exercises',
      where: 'list_id = ?',
      whereArgs: [listId],
    );

    List<Map<String, dynamic>> exercises = [];
    for (var entry in result) {
      var exercise = await db.query(
        'exercises',
        where: 'id = ?',
        whereArgs: [entry['exercise_id']],
      );
      if (exercise.isNotEmpty) {
        var fullExercise = Map<String, dynamic>.from(exercise.first);
        fullExercise['serie'] = entry['serie'];
        fullExercise['repeticoes'] = entry['repeticoes'];
        fullExercise['kg'] = entry['kg'];
        fullExercise['tempo_entre_series'] = entry['tempo_entre_series'];
        exercises.add(fullExercise);
      }
    }
    return exercises;
  }

  Future<List<Map<String, dynamic>>> getWorkoutLists() async {
    Database db = await database;
    var result = await db.query('workout_lists');
    return result.map((item) => item.cast<String, dynamic>()).toList();
  }

  Future<void> renameWorkoutList(int id, String newName) async {
    Database db = await database;
    await db.update(
      'workout_lists',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteWorkoutList(int id) async {
    Database db = await database;
    await db.delete(
      'workout_lists',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteExerciseFromWorkoutList(int listId, String exerciseId) async {
    Database db = await database;
    await db.delete(
      'workout_list_exercises',
      where: 'list_id = ? AND exercise_id = ?',
      whereArgs: [listId, exerciseId],
    );
  }
  
  Future<void> addExerciseToWorkoutList(int listId, String exerciseId, int serie, int repeticoes, double kg, int tempoEntreSeries) async {
    Database db = await database;
    await db.insert(
      'workout_list_exercises',
      {
        'list_id': listId,
        'exercise_id': exerciseId,
        'serie': serie,
        'repeticoes': repeticoes,
        'kg': kg,
        'tempo_entre_series': tempoEntreSeries
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> updateExerciseInWorkoutList(int listId, String exerciseId, int serie, int repeticoes, double kg, int tempoEntreSeries) async {
    Database db = await database;
    await db.update(
      'workout_list_exercises',
      {
        'serie': serie,
        'repeticoes': repeticoes,
        'kg': kg,
        'tempo_entre_series': tempoEntreSeries
      },
      where: 'list_id = ? AND exercise_id = ?',
      whereArgs: [listId, exerciseId],
    );
  }

  Future<void> ensureDefaultWorkoutList() async {
    Database db = await database;
    var result = await db.query('workout_lists');
    if (result.isEmpty) {
      await insertWorkoutList('Workout 1', []);
    }
  }
}