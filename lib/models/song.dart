import 'package:uuid/uuid.dart';

class Song {
  late String? id = Uuid().v4();
  late String? name;
  late String? path;
  late bool? loved;
  late DateTime? added;
  late DateTime? lastPlayed;

  Song({this.id, this.name, this.loved, this.added, this.lastPlayed});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'loved': loved,
      'added': added,
      'lastPlayer': lastPlayed
    };
  }

  Song fromMapEntry(Map mapEntry) {
    id = mapEntry['id'];
    name = mapEntry['name'];
    path = mapEntry['path'];
    loved = mapEntry['loved'];
    added = mapEntry['added'];
    lastPlayed = mapEntry['lastPlayed'];

    return this;
    // return Song(
    //   id: mapEntry['id'],
    //   name: mapEntry['name'],
    //   loved: mapEntry['loved'],
    //   added: mapEntry['added'],
    //   lastPlayed: mapEntry['lastPlayed'],
    // );
  }

  @override
  String toString() {
    return 'Project{id: $id, name: $name, path: $path, loved: $loved, added: $added, lastPlayed: $lastPlayed}';
  }
}
