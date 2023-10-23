import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddMusicSongList extends StatefulWidget {
  final Playlist? playlist;
  AddMusicSongList(this.playlist);

  @override
  State<AddMusicSongList> createState() => _AddMusicSongListState();
}

class _AddMusicSongListState extends State<AddMusicSongList> {
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilderWrapper(_getSongs, (context, snapshot) {
          List<Song> songs = snapshot.data;
          if (songs.isNotEmpty) {
            return Column(
              children: [...songs.map((song) => _SongTileForAddMusic(song))],
            );
          } else {
            return Text("No songs.");
          }
        }),
      ],
    );
  }
}

class _SongTileForAddMusic extends StatefulWidget {
  final Song song;
  _SongTileForAddMusic(this.song);

  @override
  State<_SongTileForAddMusic> createState() => _SongTileForAddMusicState();
}

class _SongTileForAddMusicState extends State<_SongTileForAddMusic> {
  late Song song = widget.song;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return ListTileWrapper(
        title: song.name!,
        leading: Icon(Icons.play_circle_outline),
        trailing: IconButton(
          icon: isSelected
              ? Icon(Icons.check_circle)
              : Icon(Icons.add_circle_outline),
          onPressed: () {
            print('select ${song.id}: ${song.name}');
            setState(() {
              isSelected = !isSelected;
            });
          },
        ),
        onTap: null);
  }
}
