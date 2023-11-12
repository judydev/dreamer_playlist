import 'package:uuid/uuid.dart';
import 'dart:convert';

class Playlist {
  late String id;
  late String? name;
  int? loved = 0;
  late int? added;
  int? lastPlayed;
  int? lastUpdated;
  List<int>? indices;

  Playlist(
      {this.name})
      : id = Uuid().v4(),
        added = DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'loved': loved,
      'added': added,
    };
  }

  Playlist fromMapEntry(Map entry) {
    id = entry['id'];
    name = entry['name'];
    loved = entry['loved'];
    added = entry['added'];
    lastPlayed = entry['lastPlayed'];
    lastUpdated = entry['lastUpdated'];
    String? indicesStr = entry['indices'];
    if (indicesStr != null) {
      try {
        indices = json.decode(indicesStr).cast<int>().toList();
      } catch (e) {
        print('Error parsing playlist indices');
        print(e);
      }
    }

    return this;
  }

  @override
  String toString() {
    return 'Playlist{id: $id, name: $name, loved: $loved, added: $added, lastPlayed: $lastPlayed, lastUpdated: $lastUpdated}';
  }
}
