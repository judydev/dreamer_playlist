import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/providers/database_util.dart';
import 'package:flutter/material.dart';

class AppStateDataProvider extends ChangeNotifier {
  Future<Map<String, dynamic>> getAppStates() async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseUtil.appstateTableName);
    print('getAppStates');
    print(maps);
    Map<String, dynamic> appStates = {};
    for (var state in maps) {
      appStates[state['key']] = state['value'];
    }
    print(appStates);
    return appStates;
  }

  Future<void> updateAppState(AppStateKey key, String? value) async {
    final db = await DatabaseUtil.getDatabase();

    await db.update(DatabaseUtil.appstateTableName, {'value': value},
        where: 'key = ?', whereArgs: [key.name]);
    notifyListeners();
  }

  Future<void> updateCurrentTab(CurrentTab tab) async {
    print('updateTab');
    final db = await DatabaseUtil.getDatabase();
    await db.update(DatabaseUtil.appstateTableName, {'value': tab.name},
        where: 'key = ?', whereArgs: [AppStateKey.currentTab.name]);
    notifyListeners();
  }
}
