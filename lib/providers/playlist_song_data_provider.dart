import 'package:dreamer_playlist/models/playlist_song.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/database_util.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PlaylistSongDataProvider extends ChangeNotifier {
  Future<void> associateSongToPlaylist(String songId, String playlistId) async {
    final db = await DatabaseUtil.getDatabase();

    PlaylistSong relation = PlaylistSong(
        songId: songId,
        playlistId: playlistId,
        added: DateTime.now().millisecondsSinceEpoch);
    await db.insert(
      DatabaseUtil.playlistSongTableName,
      relation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  Future<List<Song>> getAllSongsFromPlaylist(String playlistId) async {
    final db = await DatabaseUtil.getDatabase();
    String sql =
        'select * from ${DatabaseUtil.songTableName} where id in (select songId from ${DatabaseUtil.playlistSongTableName} where playlistId = "$playlistId")';
    List<Map<String, dynamic>> maps = await db.rawQuery(sql);

    List<Song> songs =
        List.generate(maps.length, (i) => Song().fromMapEntry(maps[i])
    );

    return songs;
  }

  Future<void> removeSongFromPlaylist(String songId, String playlistId) async {
    final db = await DatabaseUtil.getDatabase();

    await db.delete(DatabaseUtil.playlistSongTableName,
        where: 'songId = ? AND playlistId = ?',
        whereArgs: [songId, playlistId]);

    notifyListeners();
  }
}
