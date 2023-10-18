import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseUtil {
  static Future<Database> initDatabase() async {
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'dreamer_playlist.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE projects(id VARCHAR(16) PRIMARY KEY, name TEXT NOT NULL, description TEXT);');
        db.execute('CREATE TABLE appstate(key TEXT PRIMARY KEY, value TEXT);');
        db.execute(
            'INSERT INTO appstate ("key", "value") VALUES("currentProjectId", NULL)');
        return;
      },
      version: 1,
    );
    return await database;
  }

  static Future<Database> getDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'dreamer_playlist.db'),
    );
    return await database;
  }
}
