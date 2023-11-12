import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseUtil {
  static const appDbName = 'dreamer_playlist.db';
  static const appstateTableName = 'AppState';
  static const songTableName = 'Song';
  static const playlistTableName = 'Playlist';
  static const playlistSongTableName = 'Playlist_Song';

  static Future<Database> initDatabase() async {
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), appDbName),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE $appstateTableName (key TEXT PRIMARY KEY, value TEXT);');
        db.execute(
            'INSERT INTO $appstateTableName ("key", "value") VALUES("currentTab", "Library")');
        db.execute(
            'INSERT INTO $appstateTableName ("key", "value") VALUES("currentPlaying", NULL)');
        db.execute(
            'INSERT INTO $appstateTableName ("key", "value") VALUES("currentPlaylistId", NULL)');
        db.execute(
            'INSERT INTO $appstateTableName ("key", "value") VALUES("lastPlayed", NULL)');
        db.execute(
            'INSERT INTO $appstateTableName ("key", "value") VALUES("language", "EN")');
        db.execute(
            'INSERT INTO $appstateTableName ("key", "value") VALUES("darkMode", "false")');
        db.execute(
            'CREATE TABLE $songTableName (id VARCHAR(16) PRIMARY KEY, name TEXT NOT NULL, path TEXT, loved BOOL, added INTEGER, lastPlayed INTEGER);');
        db.execute(
            'CREATE TABLE $playlistTableName (id VARCHAR(16) PRIMARY KEY, name TEXT NOT NULL, loved BOOL, added INTEGER, lastPlayed INTEGER, lastUpdated INTEGER, sortMode VARCHAR(32), indices TEXT);');
        db.execute(
            'CREATE TABLE $playlistSongTableName (id VARCHAR(16) PRIMARY KEY, playlistId VARCHAR(16), songId VARCHAR(16), added INTEGER, lastPlayed INTEGER, FOREIGN KEY (playlistId) REFERENCES Playlist (id) ON DELETE CASCADE, FOREIGN KEY (songId) REFERENCES Song (id) ON DELETE CASCADE);');

        return;
      },
      version: 1,
    );
    return await database;
  }

  static Future<Database> getDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), appDbName),
    );
    return await database;
  }
}
