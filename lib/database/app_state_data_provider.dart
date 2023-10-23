import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/database/database_util.dart';
import 'package:flutter/material.dart';

class AppStateDataProvider extends ChangeNotifier {
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

  // Future<AppStates> getAppStates3() async {
  //   final db = await DatabaseUtil.getDatabase();
  //   final List<Map<String, dynamic>> maps =
  //       await db.query(DatabaseUtil.appstateTableName);
  //   // Map<AppStateKey, dynamic> appStates = {};
  //   print(maps);

  //   AppStates appStates = AppStates();

  //   print('for');
  //   for (var state in maps) {
  //     print(state.values);
  //     String? val = state.values.last;
  //     print(val);
  //     switch (state.values.first) {
  //       case 'currentTab':
  //         appStates.currentTab = val;
  //         break;
  //       case 'currentPlaying':
  //         appStates.currentPlaying = val;
  //         break;
  //       case 'currentPlaylistId':
  //         appStates.currentPlaylistId = val;
  //         break;
  //       case 'lastPlayed':
  //         appStates.lastPlayed = val;
  //         break;
  //       case 'language':
  //         appStates.language = val!;
  //         break;
  //       case 'darkMode':
  //         appStates.darkMode = val == 'true';
  //         break;
  //       default:
  //         print('unknown state key');
  //     }
  //     // appStates.currentTab =
  //     // appStates[getAppStateKeyFromString(state['key'])] = state['value'];
  //   }

  //   print('appStatessss');
  //   print(appStates.toString());
  //   return appStates;
  // }

  // Future<Map<AppStateKey, dynamic>> getAppStates2() async {
  //   final db = await DatabaseUtil.getDatabase();
  //   final List<Map<String, dynamic>> maps =
  //       await db.query(DatabaseUtil.appstateTableName);
  //   Map<AppStateKey, dynamic> appStates = {};
  //   print(maps);
  //   for (var state in maps) {
  //     appStates[getAppStateKeyFromString(state['key'])] = state['value'];
  //   }

  //   return appStates;
  // }

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
    notifyListeners();
  }


  // Future<void> updateCurrentTab(String tab) async {
  //   final db = await DatabaseUtil.getDatabase();
  //   await db.update(DatabaseUtil.appstateTableName, {'value': tab},
  //       where: 'key = ?', whereArgs: [AppStateKey.currentTab.name]);
  //   notifyListeners();
  // }

  // Future<void> updateCurrentTab2(CurrentTab tab) async {
  //   final db = await DatabaseUtil.getDatabase();
  //   await db.update(DatabaseUtil.appstateTableName, {'value': tab.name},
  //       where: 'key = ?', whereArgs: [AppStateKey.currentTab.name]);
  //   notifyListeners();
  // }
}
