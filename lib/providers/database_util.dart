import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseUtil {
  //extends ChangeNotifier
  static Future<Database> initDatabase() async {
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'dreamer_app.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE projects(id VARCHAR(16) PRIMARY KEY, name TEXT NOT NULL, description TEXT, created DATETIME, updated DATETIME);');
        db.execute('CREATE TABLE appstate(key TEXT PRIMARY KEY, value TEXT);');
        db.execute(
            'INSERT INTO appstate ("key", "value") VALUES("currentProjectId", NULL)');
        db.execute(
            'CREATE TABLE project_sections(id TEXT PRIMARY KEY, projectId TEXT NOT NULL, sectionOrder INTEGER, audioFileId TEXT, recordingFileId TEXT, lyricsId TEXT)');
        db.execute(
            'CREATE TABLE files(id TEXT PRIMARY KEY, name TEXT NOT NULL, type TEXT, path TEXT)');
        db.execute('CREATE TABLE lyrics(id TEXT PRIMARY KEY, value TEXT)');
        return;
      },
      version: 1,
    );
    return await database;
  }

  static Future<Database> getDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'dreamer_app.db'),
    );
    return await database;
  }
}
