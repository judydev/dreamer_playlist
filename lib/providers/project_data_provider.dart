import 'package:dreamer_app/models/project.dart';
import 'package:dreamer_app/providers/database_util.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ProjectDataProvider extends ChangeNotifier {
  Future<void> addProject(Project project) async {
    final db = await DatabaseUtil.getDatabase();

    await db.insert(
      'projects',
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  Future<List<Project>> getAllProjects() async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('projects');

    List<Project> projects = List.generate(maps.length, (i) {
      return Project(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
      );
    });

    return projects;
  }

  Future<Project?> getProjectById(String id) async {
    print('id = $id');
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('projects', where: 'id = "$id"');
    if (maps.isEmpty) {
      return null;
    }
    return Project(
        id: id, name: maps[0]['name'], description: maps[0]['description']);
  }

  Future<void> updateProject(Project project) async {
    final db = await DatabaseUtil.getDatabase();

    await db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );

    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    final db = await DatabaseUtil.getDatabase();

    await db.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );

    notifyListeners();
  }
}
