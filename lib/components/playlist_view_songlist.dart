import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class PlaylistViewSongList extends StatefulWidget {
  final Playlist? playlist;
  PlaylistViewSongList(this.playlist);

  @override
  State<PlaylistViewSongList> createState() => _PlaylistViewSongListState();
}

class _PlaylistViewSongListState extends State<PlaylistViewSongList> {
  late Playlist? playlist = widget.playlist;

  late SongDataProvider songDataProvider;
  late Future<List<Song>> _getSongs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    songDataProvider = Provider.of<SongDataProvider>(context);
    if (playlist != null) {
      _getSongs = songDataProvider.getAllSongsFromPlaylist(playlist!.id);
    } else {
      _getSongs = songDataProvider.getAllSongs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
        Expanded(
      child: FutureBuilderWrapper(_getSongs,
          // loadingText: 'Loading songs...',
          (context, snapshot) {
        List<Song> songs = snapshot.data;
        if (songs.isNotEmpty) {
          GetitUtil.songList = songs;
          final playlistAudioSource = ConcatenatingAudioSource(
            useLazyPreparation:
                true, 
            children: [
              ...songs
                  .map((song) => AudioSource.file(song.path!, tag: song.name)),
            ],
          );
        
          GetitUtil.audioPlayer.setAudioSource(playlistAudioSource,
              initialIndex: 0, initialPosition: Duration.zero);

          return ListView(children: [
            ...songs.map((song) => SongTile(
                  song,
                  currentPlaylistId: playlist?.id,
                ))
          ]);
        } else {
          return Text("No songs.");
        }
      }),
    );
  }
}
