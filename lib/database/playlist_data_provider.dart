import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/database_util.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PlaylistDataProvider extends ChangeNotifier {
  final PlaylistDataService _playlistDataService;
  PlaylistDataProvider(this._playlistDataService);
  
  Future<String> createPlaylist(String name) async {
    String playlistId = await _playlistDataService.createPlaylist(name);
    notifyListeners();
    return playlistId;
  }

  Future<void> updatePlaylistName(String playlistId, String newName) async {
    await _playlistDataService.updatePlaylistName(playlistId, newName);
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    await _playlistDataService.deletePlaylist(id);
    notifyListeners();
  }

  Future<void> updatePlaylistFavorite(Playlist playlist) async {
    _playlistDataService.updatePlaylistFavorite(playlist);
    notifyListeners();
  }
}

class PlaylistFavoriteNotifier with ChangeNotifier {
  int? _loved;
  int? get loved => _loved;

  PlaylistFavoriteNotifier(this._loved);

  Future<int?> updatePlaylistFavorite(Playlist playlist) async {
    if (_loved == null) {
      _loved = 1;
    } else {
      _loved = _loved == 1 ? 0 : 1;
    }
    notifyListeners();
    return _loved;
  }
}

class PlaylistDataService {
  // singleton
  PlaylistDataService._privateConstructor();
  static final PlaylistDataService _instance = PlaylistDataService._privateConstructor();
  // static PlaylistDataService get instance => _instance;
  factory PlaylistDataService() {
    return _instance;
  }

  Future<String> createPlaylist(String name) async {
    final db = await DatabaseUtil.getDatabase();

    Playlist playlist = Playlist(name: name);
    await db.insert(
      DatabaseUtil.playlistTableName,
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

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
      await db.query(
        DatabaseUtil.playlistTableName,
        where: 'id = ?',
        whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }

    Playlist playlist = Playlist().fromMapEntry(maps[0]);
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
      debugPrint('Error updating playlist name: $e');
    }
  }

  Future<void> deletePlaylist(String id) async {
    final db = await DatabaseUtil.getDatabase();

    // delete playlist song from database
    try {
      await db.delete(DatabaseUtil.playlistSongTableName,
          where: 'playlistId = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint(
          'Error removing song playlist relations where playlistId = $id: $e');
    }

    // delete playlist entry from database
    try {
      await db.delete(
        DatabaseUtil.playlistTableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting playlist from db: $e');
    }
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
    try {
      await db.update(DatabaseUtil.playlistTableName,
          {'loved': playlist.loved == 0 ? 1 : 0},
          where: 'id = ?', whereArgs: [playlist.id]);
    } catch (e) {
      debugPrint('Error updating playlist favorite: $e');
    }
  }
}
