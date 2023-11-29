import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:uuid/uuid.dart';

class Song {
  late String? id;
  late String? title;
  late String? relativePath;
  int? loved = 0;
  late int? added;
  int? lastPlayed;
  File? audioFile;
  String? playlistSongId; // used when loading a song from a playlist

  Song({this.title, this.relativePath, this.added}) : id = Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': title,
      'path': relativePath,
    };
  }

  factory Song.fromMediaItem(MediaItem mediaItem) {
    return Song(
      title: mediaItem.title,
      relativePath: mediaItem.extras!['path'],
      added: mediaItem.extras!['added'],
    );
  }

  MediaItem toMediaItem() =>
      MediaItem(
      id: id!, title: title!, extras: {'path': relativePath, 'added': added});

  Song fromMapEntry(Map mapEntry) {
    id = mapEntry['id'];
    title = mapEntry['name'];
    relativePath = mapEntry['path'];
    loved = mapEntry['loved'];
    added = mapEntry['added'];
    lastPlayed = mapEntry['lastPlayed'];
    playlistSongId = mapEntry['playlistSongId'];

    return this;
  }

  @override
  String toString() {
    return '{title: $title, path: $relativePath}';
    // return 'Song{id: $id, title: $title, path: $path, loved: $loved, added: $added, lastPlayed: $lastPlayed}';
  }
}
