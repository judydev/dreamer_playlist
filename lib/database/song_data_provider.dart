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
    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db
        .query(DatabaseUtil.songTableName, where: 'id = ?', whereArgs: [id]);
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

    // find all playlist song associations where playlist indices exist
    String sql =
        '''SELECT ps.id as playlistSongId, ps.playlistId FROM ${DatabaseUtil.playlistSongTableName} AS ps 
        JOIN ${DatabaseUtil.playlistTableName} AS p ON ps.playlistId = p.id 
        WHERE ps.songId = "${song.id}" AND p.indices IS NOT NULL;''';

    final maps = await db.rawQuery(sql);

    // for each association, check if playlist has indices defined
    if (maps.isNotEmpty) {
      // group maps with playlistId
      Map<String, List<String>> grouped = {};
      for (Map map in maps) {
        String playlistId = map['playlistId'];
        String playlistSongId = map['playlistSongId'];
        if (!grouped.containsKey(playlistId)) {
          grouped[playlistId] = [];
        }
        grouped[playlistId]!.add(playlistSongId);
      }

      // remove songs from each playlist to update playlist indices
      for (String playlistId in grouped.keys) {
        await updatePlaylistIndicesWhenRemovingSongsFromPlaylist(
            grouped[playlistId]!, playlistId);
      }
    }

    // delete playlist song from database
    try {
      await db.delete(DatabaseUtil.playlistSongTableName,
          where: 'songId = ?', whereArgs: [song.id]);
    } catch (e) {
      debugPrint(
          'Error removing song playlist relations where songId = ${song.id}: $e');
    }

    // delete song entry from database
    try {
      await db.delete(
        DatabaseUtil.songTableName,
        where: 'id = ?',
        whereArgs: [song.id],
      );
    } catch (e) {
      debugPrint('error deleting song: $e');
      return;
    }

    // remove local storage file
    StorageProvider().deleteSongFileFromLocalStorage(song.path!);

    // verify there is no Song left with given path (is this necessary?)
    final checkSongs = await db.query(DatabaseUtil.songTableName,
        where: 'path = ?', whereArgs: [song.path]);
    if (checkSongs.isNotEmpty) {
      debugPrint(
          'Something wrong: song not cleaned up where path=${song.path}');
    }

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
    try {
      await db.update(DatabaseUtil.songTableName, {'loved': loved == 1 ? 0 : 1},
        where: 'id = ?', whereArgs: [songId]);
    } catch (e) {
      debugPrint('Error updating song favorite: $e');
    }
    notifyListeners();
  }

  Future<void> updateSongsFavorite(List<String> songIds, int loved) async {
    final db = await DatabaseUtil.getDatabase();
    String sql =
        '''UPDATE ${DatabaseUtil.songTableName} SET loved = $loved WHERE id IN 
        (${idsToString(songIds)});''';

    try {
      await db.rawUpdate(sql);
    } catch (e) {
      debugPrint('Error updating songs favorite: $e');
    }
    notifyListeners();
  }

  String idsToString(List<String> ids) {
    return ids.map((id) => '"$id"').join(',');
  }

  // Playlist Songs
  Future<Set<String>> checkForDuplicateSongsInPlaylist(
      List<String> songIds, String playlistId) async {
    final db = await DatabaseUtil.getDatabase();

    String sql = '''SELECT DISTINCT s.* FROM ${DatabaseUtil.songTableName} AS s 
      JOIN ${DatabaseUtil.playlistSongTableName} AS ps
      ON s.id = ps.songId WHERE playlistId = "$playlistId" 
      AND songId IN (${idsToString(songIds)});''';

    List<Map<String, dynamic>> maps = await db.rawQuery(sql);
    Set<String> res = maps.map((e) => e['id'] as String).toSet();
    return res; // return set of duplicated songIds
  }

  Future<void> associateSongToPlaylist(String songId, String playlistId) async {
    final db = await DatabaseUtil.getDatabase();

    PlaylistSong relation = PlaylistSong(
      songId: songId,
      playlistId: playlistId,
    );

    try {
      await db.insert(
        DatabaseUtil.playlistSongTableName,
        relation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error adding song to playlist: $e');
    }

    // update playlist indices
    List<int>? indices = await getPlaylistIndices(playlistId);
    if (indices != null) {
      indices.add(indices.length);
      await updatePlaylistIndices(playlistId, indices);
    }

    notifyListeners();
  }

  Future<List<Song>> getAllSongsFromPlaylist(String playlistId) async {
    final db = await DatabaseUtil.getDatabase();
    String sql =
        '''SELECT s.name, s.path, s.loved, s.added, s.lastPlayed, s.id AS id, ps.id AS playlistSongId 
          FROM ${DatabaseUtil.songTableName} AS s JOIN ${DatabaseUtil.playlistSongTableName} AS ps 
          ON s.id = ps.songId WHERE ps.playlistId = "$playlistId";''';
    List<Map<String, dynamic>> maps = await db.rawQuery(sql);

    List<int>? indices = await getPlaylistIndices(playlistId);
    if (indices != null) {
      if (indices.length != maps.length) {
        debugPrint(
            'getAllSongsFromPlaylist: something wrong with playlist indices');
      } else {
        try {
          return List.generate(
              maps.length, (i) => Song().fromMapEntry(maps[indices[i]]));
        } catch (e) {
          debugPrint(
              'error generating playlist songs based on playlist indices: $e');
          debugPrint('indices=$indices');
        }
      }
    }
    
    return List.generate(maps.length, (i) => Song().fromMapEntry(maps[i]));
  }

  Future<void> removeSongsFromPlaylist(
      List<String> playlistSongIds, String playlistId) async {
    final db = await DatabaseUtil.getDatabase();

    // verify if playlistSongIds belong to playlistId
    bool verified = await verifyPlaylistSongIds(playlistSongIds, playlistId);
    if (!verified) return;

    // update playlist indices
    await updatePlaylistIndicesWhenRemovingSongsFromPlaylist(
        playlistSongIds, playlistId);
    
    // remove association of playlist and song
    String sql = '''DELETE FROM ${DatabaseUtil.playlistSongTableName} 
      WHERE id IN (${idsToString(playlistSongIds)});''';

    try {
      await db.rawDelete(sql);
    } catch (e) {
      debugPrint('Error removing songs from playlist: $e');
    }

    // verifyPlaylistIndices(playlistId)
    notifyListeners();
  }

  Future<void> updatePlaylistIndicesWhenRemovingSongsFromPlaylist(
      List<String> playlistSongIds, String playlistId) async {
    List<int>? indices = await getPlaylistIndices(playlistId);
    if (indices == null) return;

    List<String> allPlaylistSongIds =
        (await getAllSongsFromPlaylist(playlistId))
            .map((e) => e.playlistSongId!)
            .toList();
    Set<int> indicesToBeRemoved = {};

    for (String psId in playlistSongIds) {
      int foundIndex = allPlaylistSongIds.indexOf(psId);
      if (foundIndex < 0) {
        debugPrint(
            'Something wrong with playlistSongId, does not match given playlistId');
      }
      indicesToBeRemoved.add(foundIndex);
    }
    indices.removeWhere(((element) => indicesToBeRemoved.contains(element)));
    List<int> sortedIndices = List.from(indices);
    sortedIndices.sort();

    List<int> reordered = indices.map((e) => sortedIndices.indexOf(e)).toList();
    await updatePlaylistIndices(playlistId, reordered);
  }

  Future<bool> verifyPlaylistSongIds(
      List<String> playlistSongIds, String playlistId) async {
    final db = await DatabaseUtil.getDatabase();

    String sql =
        '''SELECT DISTINCT playlistId FROM ${DatabaseUtil.playlistSongTableName} 
        WHERE id IN (${idsToString(playlistSongIds)});''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql);
    if (maps.length != 1) {
      debugPrint('Something wrong with provided playlistSongIds');
      return false;
    }

    return true;
  }

  Future<List<int>?> getPlaylistIndices(String playlistId) async {
    final db = await DatabaseUtil.getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
        DatabaseUtil.playlistTableName,
        columns: ['indices'],
        where: 'id = ?',
        whereArgs: [playlistId]);

    String? strIndices = maps[0]['indices'];
    if (strIndices == null) return null;

    // verifyPlaylistIndices(playlistId);

    List<int>? indices;
    try {
      indices = parsePlaylistIndices(strIndices);
    } catch (e) {
      debugPrint('error parsing playlist indices: $e');
    }

    return indices;
  }

  List<int> parsePlaylistIndices(String strIndices) {
    try {
      return strIndices
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map(
            (e) => int.parse(e),
          )
          .toList();
    } catch (e) {
      debugPrint('error parsing playlist indices: $e');
      rethrow;
    }
  }

  Future<void> updatePlaylistIndices(
      String playlistId, List<int> indices) async {
    final db = await DatabaseUtil.getDatabase();

    try {
      await db.update(
          DatabaseUtil.playlistTableName,
          indices.isEmpty ? {'indices': null} : {'indices': indices.toString()},
          where: 'id = ?', whereArgs: [playlistId]);
    } catch (e) {
      debugPrint('error updating playlist indices: $e');
    }

    // verifyPlaylistIndices(playlistId);

    notifyListeners();
  }

  Future<String> verifyPlaylistIndices(
    BuildContext context, {
    required String playlistId,
    required String playlistName,
    String? strIndices,
  }) async {
    final db = await DatabaseUtil.getDatabase();

    if (strIndices == null) {
      final maps = await db.query(DatabaseUtil.playlistTableName,
          columns: ['indices'], where: 'id = ?', whereArgs: [playlistId]);
      strIndices = maps[0]['indices'].toString();
    }

    List<int> indices;
    try {
      indices = parsePlaylistIndices(strIndices);
    } catch (e) {
      return 'Not an integer list. ';
    }

    // verify indices length matches playlist songs count
    String sqlCount =
        '''SELECT COUNT(*) AS count FROM ${DatabaseUtil.playlistSongTableName} 
          WHERE playlistId = "$playlistId";''';

    final countMap = await db.rawQuery(sqlCount);
    int count = int.parse(countMap[0]['count'].toString());
    if (indices.length != count) {
      return 'Wrong indices length. ';
    }

    // verify int sequence
    List<int> generated = List.generate(indices.length, (i) => i);
    indices.sort();
    if (indices.toString() != generated.toString()) {
      return 'Wrong integer sequence. ';
    }

    return '';
  }
}
