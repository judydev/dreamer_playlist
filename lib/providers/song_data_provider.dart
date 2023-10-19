import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/database_util.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class SongDataProvider extends ChangeNotifier {
  Future<void> addSong(Song song) async {
    final db = await DatabaseUtil.getDatabase();

    await db.insert(
      DatabaseUtil.songTableName,
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  Future<List<Song>> getAllSongs() async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseUtil.songTableName);

    List<Song> songs = List.generate(maps.length, (i) {
      // return buildSongObjectFromMap(maps[i]);
      return Song().fromMapEntry(maps[i]);
    });

    return songs;
  }

  Song buildSongObjectFromMap(Map mapEntry) {
    return Song(
      id: mapEntry['id'],
      name: mapEntry['name'],
      loved: mapEntry['loved'],
      added: mapEntry['added'],
      lastPlayed: mapEntry['lastPlayed'],
    );
  }

  Future<Song?> getSongById(String id) async {
    print('id = $id');
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseUtil.songTableName, where: 'id = "$id"');
    if (maps.isEmpty) {
      return null;
    }
    return buildSongObjectFromMap(maps[0]);
  }

  Future<void> updateSong(Song song) async {
    final db = await DatabaseUtil.getDatabase();

    await db.update(
      DatabaseUtil.songTableName,
      song.toMap(),
      where: 'id = ?',
      whereArgs: [song.id],
    );

    notifyListeners();
  }

  Future<void> deleteSong(String id) async {
    final db = await DatabaseUtil.getDatabase();

    await db.delete(
      DatabaseUtil.songTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    notifyListeners();
  }
}
