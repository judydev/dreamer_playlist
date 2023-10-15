import 'package:dreamer_app/models/project.dart';
import 'package:dreamer_app/providers/database_util.dart';
import 'package:dreamer_app/providers/project_data_provider.dart';
import 'package:flutter/material.dart';

class AppStateDataProvider extends ChangeNotifier {
  Future<Map<String, dynamic>> getAppState() async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('appstate');
    Map<String, dynamic> appStates = {};
    for (var state in maps) {
      appStates[state['key']] = state['value'];
    }
    return appStates;
  }

  Future<Project?> getCurrentProjectAppState() async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('appstate',
        columns: ["value"], where: 'key == "currentProjectId"');

    if (maps.isEmpty) {
      throw Exception("currentProjectId app state missing");
    }

    String? currentProjectId = maps[0]['value'];
    if (currentProjectId == null) {
      return null;
    } else {
      return ProjectDataProvider().getProjectById(currentProjectId);
    }
  }

  Future<void> updateCurrentProjectAppState(String? currentProjectId) async {
    final db = await DatabaseUtil.getDatabase();

    await db.rawUpdate('update appstate SET value = ? WHERE key = ?',
        [currentProjectId, 'currentProjectId']);
    notifyListeners();
  }
}
