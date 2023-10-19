import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/providers/database_util.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PlaylistDataProvider extends ChangeNotifier {
  Future<void> addPlaylist(Playlist playlist) async {
    final db = await DatabaseUtil.getDatabase();

    await db.insert(
      DatabaseUtil.playlistTableName,
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseUtil.playlistTableName);

    List<Playlist> playlists = List.generate(maps.length, (i) {
      return Playlist().fromMapEntry(maps[i]);
    });

    return playlists;
  }

  Future<Playlist?> getPlaylistById(String id) async {
    print('id = $id');
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseUtil.playlistTableName, where: 'id = "$id"');
    if (maps.isEmpty) {
      return null;
    }
    return Playlist().fromMapEntry(maps[0]);
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    final db = await DatabaseUtil.getDatabase();

    await db.update(
      DatabaseUtil.playlistTableName,
      playlist.toMap(),
      where: 'id = ?',
      whereArgs: [playlist.id],
    );

    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    final db = await DatabaseUtil.getDatabase();

    await db.delete(
      DatabaseUtil.playlistTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    notifyListeners();
  }
}
