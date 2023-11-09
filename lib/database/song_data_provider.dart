import 'dart:io';

import 'package:dreamer_playlist/models/playlist_song.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/database_util.dart';
import 'package:dreamer_playlist/database/storage_provider.dart';
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
    String strippedName = StorageProvider.getFilenameFromPlatformFile(
        selectedFile.name, selectedFile.extension!);
    Song song = Song(title: strippedName, path: songFile.path);
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

  Future<void> updateSongName(String songId, String name) async {
    final db = await DatabaseUtil.getDatabase();

    await db.update(DatabaseUtil.songTableName, {'name': name},
        where: 'id = ?', whereArgs: [songId]);

    notifyListeners();
  }

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

  // Playlist Songs
  Future<Set<String>> checkIfSongsExistInPlaylist(
      List<String> songIds, String playlistId) async {
    final db = await DatabaseUtil.getDatabase();

    String sql = '''
          SELECT DISTINCT s.* FROM ${DatabaseUtil.songTableName} AS s JOIN ${DatabaseUtil.playlistSongTableName} AS ps
          ON s.id = ps.songId WHERE playlistId = "$playlistId" AND songId IN (
            ${songIds.map(
              (id) => '"$id"',
            ).toList().join(',')}
          )
        ''';

    List<Map<String, dynamic>> maps = await db.rawQuery(sql);
    Set<String> res = maps.map((e) => e['id'] as String).toSet();
    return res; // return set of duplicated songIds
  }

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
        '''
          SELECT s.name, s.path, s.loved, s.added, s.lastPlayed, s.id AS id, ps.id AS playlistSongId 
          FROM ${DatabaseUtil.songTableName} AS s JOIN ${DatabaseUtil.playlistSongTableName} AS ps 
          ON s.id = ps.songId WHERE ps.playlistId = "$playlistId"
        ''';
    List<Map<String, dynamic>> maps = await db.rawQuery(sql);

    List<Song> songs =
        List.generate(maps.length, (i) => Song().fromMapEntry(maps[i]));

    return songs;
  }

  Future<void> removeSongFromPlaylist(String playlistSongId) async {
    final db = await DatabaseUtil.getDatabase();

    await db.delete(DatabaseUtil.playlistSongTableName,
        where: 'id = ?', whereArgs: [playlistSongId]);

    // TODO: handle exception
    notifyListeners();
  }
}
