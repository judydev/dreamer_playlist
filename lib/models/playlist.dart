import 'package:uuid/uuid.dart';

class Playlist {
  late String id;
  late String? name;
  int? loved = 0;
  late int? added;
  late int? lastPlayed;
  late int? lastUpdated;

  Playlist(
      {this.name, this.lastPlayed, this.lastUpdated})
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

    return this;
  }

  @override
  String toString() {
    return 'Playlist{id: $id, name: $name, loved: $loved, added: $added, lastPlayed: $lastPlayed, lastUpdated: $lastUpdated}';
  }
}
