import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistEditSongList extends StatefulWidget {
  final Playlist playlist;
  PlaylistEditSongList(this.playlist);

  @override
  State<PlaylistEditSongList> createState() => _PlaylistEditSongListState();
}

class _PlaylistEditSongListState extends State<PlaylistEditSongList> {
  late Playlist playlist = widget.playlist;
  // late AudioPlayer _player;

  late SongDataProvider songDataProvider;
  late Future<List<Song>> _getSongs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    songDataProvider = Provider.of<SongDataProvider>(context);
    _getSongs = songDataProvider.getAllSongsFromPlaylist(playlist.id);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilderWrapper(_getSongs,
            // loadingText: 'Loading songs...',
            (context, snapshot) {
          List<Song> songs = snapshot.data;
          if (songs.isNotEmpty) {
            // set playlist audio sources

            return Column(
              children: [...songs.map((song) => SongTile(song))], 
            );
          } else {
            return Text("No songs in this playlist.");
          }
        }),
      ],
    );
  }
}
