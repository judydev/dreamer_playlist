import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/database/database_util.dart';
import 'package:flutter/material.dart';

class AppStateDataProvider extends ChangeNotifier {
  final AppStateDataService _appStateDataService;

  AppStateDataProvider(this._appStateDataService);

  List<AppState> _appStates = [];

  List<AppState> get appStates => _appStates;
 
  Future<Map<String, dynamic>> getAppStates() async {
    return await _appStateDataService.getAppStates();
  }

  Future<String?> getAppStateByKey(AppStateKey key) async {
    return await _appStateDataService.getAppStateByKey(key);
  }

  Future<void> updateAppState(AppStateKey key, String? value) async {
    await _appStateDataService.updateAppState(key, value);
    notifyListeners();
  }
}

class AppStateDataService {
  Future<Map<String, dynamic>> getAppStates() async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseUtil.appstateTableName);
    Map<String, dynamic> appStates = {};
    for (var state in maps) {
      appStates[state['key']] = state['value'];
    }
    return appStates;
  }

  Future<String?> getAppStateByKey(AppStateKey key) async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        DatabaseUtil.appstateTableName,
        where: 'key = ?',
        whereArgs: [key.name]);

    return maps[0]['value'];
  }

  Future<void> updateAppState(AppStateKey key, String? value) async {
    final db = await DatabaseUtil.getDatabase();
    await db.update(DatabaseUtil.appstateTableName, {'value': value},
        where: 'key = ?', whereArgs: [key.name]);
  }
}