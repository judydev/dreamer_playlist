import 'package:dreamer_playlist/providers/database_util.dart';
import 'package:flutter/material.dart';

class AppStateDataProvider extends ChangeNotifier {
  Future<Map<String, dynamic>> getAppState() async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseUtil.appstateTableName);
    Map<String, dynamic> appStates = {};
    for (var state in maps) {
      appStates[state['key']] = state['value'];
    }
    return appStates;
  }

  Future<String?> getLastPlayedAppState() async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        DatabaseUtil.appstateTableName,
        columns: ["value"],
        where: 'key = "lastPlayed"');

    if (maps.isEmpty) {
      throw Exception("currentProjectId app state missing");
    }

    String? lastPlayed = maps[0]['value'];
    return lastPlayed;
  }

  Future<void> updateLastPlayedAppState(String? lastPlayedId) async {
    final db = await DatabaseUtil.getDatabase();

    await db.rawUpdate(
        'update ${DatabaseUtil.appstateTableName} SET value = ? WHERE key = ?',
        [lastPlayedId, 'lastPlayed']);
    notifyListeners();
  }
}
