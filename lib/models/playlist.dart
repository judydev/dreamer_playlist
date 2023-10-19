import 'package:uuid/uuid.dart';

class Playlist {
  late String? id = Uuid().v4();
  late String? name;
  late bool? loved;
  late DateTime? added;
  late DateTime? lastPlayed;
  late DateTime? lastUpdated;

  Playlist(
      {this.name, this.loved, this.added, this.lastPlayed, this.lastUpdated}) {
    id ??= Uuid().v4();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'loved': loved,
      'added': added,
      'lastPlayed': lastPlayed,
      'lastUpdated': lastUpdated
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
