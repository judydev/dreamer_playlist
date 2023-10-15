import 'package:dreamer_app/models/lyrics.dart';
import 'package:dreamer_app/providers/database_util.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class LyricsDataProvider extends ChangeNotifier {
  Future<void> addLyrics(Lyrics lyrics) async {
    final db = await DatabaseUtil.getDatabase();

    await db.insert(
      'lyrics',
      lyrics.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // replace any previous data
    );

    // notifyListeners();
  }

  Future<Lyrics> getLyricsById(String? lyricsId) async {
    if (lyricsId == null) {
      return Lyrics(id: Uuid().v4(), value: null);
    }

    final db = await DatabaseUtil.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('lyrics', where: 'lyricsId = "$lyricsId"');

    if (maps.isNotEmpty) {
      return Lyrics(id: maps[0]['id'], value: maps[0]['value']);
    }

    throw Exception("error when getting lyrics id=$lyricsId");
  }
}
