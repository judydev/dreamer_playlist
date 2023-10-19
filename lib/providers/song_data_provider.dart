import 'dart:io';

import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/database_util.dart';
import 'package:dreamer_playlist/providers/storage_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class SongDataProvider extends ChangeNotifier {
  Future<List<Song>> getAllSongs() async {
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseUtil.songTableName);

    List<Song> songs =
        List.generate(maps.length, (i) => Song().fromMapEntry(maps[i]));

    return songs;
  }

  Future<Song?> getSongById(String id) async {
    print('id = $id');
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseUtil.songTableName, where: 'id = "$id"');
    if (maps.isEmpty) {
      return null;
    }
    return Song().fromMapEntry(maps[0]);
  }

  Future<Song> addSong(PlatformFile selectedFile) async {
    // Copy the file to local storage
    File songFile =
        await StorageProvider().addSongFileToLocalStorage(selectedFile);

    // build a song instance and add to database
    Song song = Song(name: selectedFile.name, path: songFile.path);
    await addSongToDb(song);

    notifyListeners();
    return song;
  }

  Future<void> addSongToDb(Song song) async {
    final db = await DatabaseUtil.getDatabase();
    song.added = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      DatabaseUtil.songTableName,
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  Future<void> updateSongName(String songId, String newName) async {}
  // Future<void> updateSong(Song song) async {
  //   final db = await DatabaseUtil.getDatabase();

  //   await db.update(
  //     DatabaseUtil.songTableName,
  //     song.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [song.id],
  //   );

  //   notifyListeners();
  // }

  Future<void> deleteSong(Song song) async {
    final db = await DatabaseUtil.getDatabase();

    // delete entry from database
    await db.delete(
      DatabaseUtil.songTableName,
      where: 'id = ?',
      whereArgs: [song.id],
    );

    // remove local storage file
    StorageProvider().deleteSongFileFromLocalStorage(song.path!);

    notifyListeners();
  }

  Future<List<Song>> getFavoriteSongs() async {
    final db = await DatabaseUtil.getDatabase();
    List<Map<String, dynamic>> maps = await db
        .query(DatabaseUtil.songTableName, where: 'loved = ?', whereArgs: [1]);

    List<Song> favSongs =
        List.generate(maps.length, (i) => Song().fromMapEntry(maps[i]));
    return favSongs;
  }

  Future<void> updateSongFavorite(String songId, int loved) async {
    final db = await DatabaseUtil.getDatabase();
    await db.update(DatabaseUtil.songTableName, {'loved': loved == 1 ? 0 : 1},
        where: 'id = ?', whereArgs: [songId]);
    // TODO: handle exceptions when update fails, and display error on UI
    notifyListeners();
  }
}
