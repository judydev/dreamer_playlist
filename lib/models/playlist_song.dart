import 'package:uuid/uuid.dart';

class PlaylistSong {
  late String? id = Uuid().v4();
  late String? playlistId;
  late String? songId;
  late DateTime? added;
  late DateTime? lastPlayed;

  PlaylistSong({this.playlistId, this.songId, this.added, this.lastPlayed})
      : id = Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playlistId': playlistId,
      'songId': songId,
      'added': added,
      'lastPlayed': lastPlayed
    };
  }

  @override
  String toString() {
    return 'PlaylistSong{id: $id, playlistId: $playlistId, songId: $songId, added: $added, lastPlayed: $lastPlayed}';
  }
}
