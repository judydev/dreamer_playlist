import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/helpers/getit_util.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SongList extends StatefulWidget {
  final Playlist? playlist;
  SongList({this.playlist});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
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
      if (GetitUtil.appStates.currentTab == menuTabs[2]) {
        _getSongs = songDataProvider.getFavoriteSongs();
      } else {
        _getSongs = songDataProvider.getAllSongs();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilderWrapper(_getSongs,
          (context, snapshot) {
        List<Song> songs = snapshot.data;
        GetitUtil.orderedSongList = songs;
        if (songs.isNotEmpty) {
          GetitUtil.setQueueFromSonglist(songs);

          return ListView(children: [
            ...songs.asMap().entries.map((entry) => SongTile(
                  entry.value,
                  songIndex: entry.key,
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
