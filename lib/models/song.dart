import 'dart:io';
import 'package:uuid/uuid.dart';

class Song {
  late String? id;
  late String? title;
  late String? path;
  int? loved = 0;
  late int? added;
  int? lastPlayed;
  File? audioFile;

  Song({this.title, this.path, this.added}) : id = Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': title,
      'path': path,
    };
  }

  Song fromMapEntry(Map mapEntry) {
    id = mapEntry['id'];
    title = mapEntry['name'];
    path = mapEntry['path'];
    loved = mapEntry['loved'];
    added = mapEntry['added'];
    lastPlayed = mapEntry['lastPlayed'];

    return this;
  }

  @override
  String toString() {
    return title.toString();
    // return 'Song{id: $id, name: $name, path: $path, loved: $loved, added: $added, lastPlayed: $lastPlayed}';
  }
}
