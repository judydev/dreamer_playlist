import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/database_util.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PlaylistDataProvider extends ChangeNotifier {
  Future<String> createPlaylist(String name) async {
    final db = await DatabaseUtil.getDatabase();
    Playlist playlist = Playlist(name: name);

    await db.insert(
      DatabaseUtil.playlistTableName,
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
    return playlist.id;
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
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseUtil.playlistTableName, where: 'id = "$id"');
    if (maps.isEmpty) {
      return null;
    }

    Playlist playlist = Playlist().fromMapEntry(maps[0]);
    // List<Song> songs = await SongDataProvider().getAllSongsFromPlaylist(id);
    // playlist.songs = songs;
    return playlist;
  }

  Future<void> updatePlaylistName(String playlistId, String newName) async {
    final db = await DatabaseUtil.getDatabase();

    try {
      await db.update(
        DatabaseUtil.playlistTableName,
        {'name': newName},
        where: 'id = ?',
        whereArgs: [playlistId],
      );
    } catch (e) {
      print('Error updating playlist name');
      print(e);
    }

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

  Future<List<Playlist>> getFavoritePlaylists() async {
    final db = await DatabaseUtil.getDatabase();

    List<Map<String, dynamic>> maps = await db.query(
        DatabaseUtil.playlistTableName,
        where: 'loved = ?',
        whereArgs: [1]);

    List<Playlist> playlists =
        List.generate(maps.length, (i) => Playlist().fromMapEntry(maps[i]));

    return playlists;
  }

  Future<void> updatePlaylistFavorite(Playlist playlist) async {
    final db = await DatabaseUtil.getDatabase();
    await db.update(
        DatabaseUtil.playlistTableName, {'loved': playlist.loved == 0 ? 1 : 0},
        where: 'id = ?', whereArgs: [playlist.id]);
    // TODO: handle exceptions when update fails, and display error on UI
    notifyListeners();
  }
}
