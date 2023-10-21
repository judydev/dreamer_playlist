import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  late AudioPlayer _player;

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
  void initState() {
    super.initState();

    _player = GetIt.instance.get<AudioPlayer>();
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
            final playlistAudioSource = ConcatenatingAudioSource(
              // Start loading next item just before reaching it
              useLazyPreparation: true,
              // Customise the shuffle algorithm
              // shuffleOrder: DefaultShuffleOrder(),
              children: [
                ...songs.map(
                    (song) => AudioSource.file(song.path!, tag: song.name)),
                // AudioSource.uri(Uri.parse('https://example.com/track1.mp3')),
              ],
            );

            _player.setAudioSource(playlistAudioSource,
                initialIndex: 0, initialPosition: Duration.zero);

            return Column(
              children: [...songs.map((song) => SongTile(song))],
            );
          } else {
            return Text("No songs.");
          }
        }),
      ],
    );
  }
}
