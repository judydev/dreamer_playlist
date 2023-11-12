// ignore_for_file: non_constant_identifier_names

import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:dreamer_playlist/database/database_util.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:flutter/material.dart';

class DataUtil {
  static Future<Map<String, dynamic>> loadInitialData() async {
    Map<String, dynamic> res = {};
    String? currentTab =
        await AppStateDataProvider().getAppStateByKey(AppStateKey.currentTab);

    AppStates appStates = AppStates();
    appStates.currentTab = currentTab;
    GetitUtil.appStates = appStates;

    return res;
  }

  void healthCheck(BuildContext context) async {
    debugPrint('health check');
    final db = await DatabaseUtil.getDatabase();

    // check for standalone PlaylistSong relations
    String sql_standalone_playlist_songs = '''
      SELECT * FROM ${DatabaseUtil.playlistSongTableName} 
      WHERE playlistId NOT IN (
        SELECT id FROM ${DatabaseUtil.playlistTableName})
      OR songId NOT IN (SELECT id FROM ${DatabaseUtil.songTableName});
    ''';
    final playlistSongs = await db.rawQuery(sql_standalone_playlist_songs);
    if (playlistSongs.isNotEmpty) {
      if (!context.mounted) return;
      await showAdaptiveDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text("Warning"),
                content:
                    const Text("Standalone PlaylistSong detected, remove?"),
                actions: [
                  displayTextButton(context, "Ignore"),
                  displayTextButton(context, "Yes", callback: () {
                    String sql_remove_standalone_playlist_songs = ''' 
                      DELETE FROM ${DatabaseUtil.playlistSongTableName}
                      WHERE playlistId NOT IN (SELECT id FROM ${DatabaseUtil.playlistTableName})
                      OR songId NOT IN (SELECT id FROM ${DatabaseUtil.songTableName});
                    ''';

                    db.rawDelete(sql_remove_standalone_playlist_songs);
                  })
                ]);
          });
    }

    // check for playlist indices
    final songDataProvider = SongDataProvider();
    String sql_playlist_indices = ''' 
      SELECT id, name, indices FROM ${DatabaseUtil.playlistTableName} 
      WHERE indices IS NOT NULL;
    ''';
    final maps = await db.rawQuery(sql_playlist_indices);
    for (Map map in maps) {
      String playlistId = map['id'];
      String playlistName = map['name'];
      String strIndices = map['indices'];

      if (!context.mounted) continue;
      String errorMessage = await songDataProvider.verifyPlaylistIndices(
          context,
          playlistId: playlistId,
          playlistName: playlistName,
          strIndices: strIndices);

      if (errorMessage.isNotEmpty) {
        if (!context.mounted) return;
        resetPlaylistIndicesPopup(context, playlistName, playlistId,
            error: errorMessage);
      }
    }
  }

  static void resetPlaylistIndicesPopup(
      BuildContext context, String playlistName, String playlistId,
      {String? error}) async {
    final db = await DatabaseUtil.getDatabase();

    if (!context.mounted) return;
    await showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Warning"),
              content: Text(
                  "Incorrect playlist indices detected for Playlist $playlistName. ${error ?? ''}Reset indices?"),
              actions: [
                displayTextButton(context, "Ignore"),
                displayTextButton(context, "Yes", callback: () {
                  db.update(DatabaseUtil.playlistTableName, {'indices': null},
                      where: 'id = ?', whereArgs: [playlistId]);
                })
              ]);
        });
  }
}
