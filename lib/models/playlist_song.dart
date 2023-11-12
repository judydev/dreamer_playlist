import 'package:uuid/uuid.dart';

class PlaylistSong {
  late String? id = Uuid().v4();
  late String? playlistId;
  late String? songId;
  int? added;
  
  // late int? lastPlayed;
  // Song? song;

  PlaylistSong({this.playlistId, this.songId})
      : id = Uuid().v4(),
        added = DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playlistId': playlistId,
      'songId': songId,
      'added': added,
    };
  }

  @override
  String toString() {
    return 'PlaylistSong{id: $id, playlistId: $playlistId, songId: $songId, added: $added}';
  }
}
