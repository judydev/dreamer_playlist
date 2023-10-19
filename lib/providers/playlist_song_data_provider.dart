import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/models/playlist_song.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/database_util.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PlaylistSongDataProvider extends ChangeNotifier {
  Future<void> associateSongToPlaylist(String songId, String playlistId) async {
    final db = await DatabaseUtil.getDatabase();

    PlaylistSong relation = PlaylistSong(
        songId: songId, playlistId: playlistId, added: DateTime.now());
    await db.insert(
      DatabaseUtil.playlistSongTableName,
      relation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  Future<List<Song>> getAllSongsFromPlaylist(String playlistId) async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        DatabaseUtil.playlistSongTableName,
        where: 'playlistId = "$playlistId"');

    List<Song> playlistSongs = List.generate(maps.length, (i) {
      return Song().fromMapEntry(maps[i]);
    });

    return playlistSongs;
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
      DatabaseUtil.playlistSongTableName,
      playlist.toMap(),
      where: 'id = ?',
      whereArgs: [playlist.id],
    );

    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    final db = await DatabaseUtil.getDatabase();

    await db.delete(
      DatabaseUtil.playlistSongTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    notifyListeners();
  }
}
