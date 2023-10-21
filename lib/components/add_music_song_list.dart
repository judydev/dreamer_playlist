import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/components/list_item_view.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/song_data_provider.dart';
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
              children: [...songs.map((song) => SongTileForAddMusic(song))],
            );
          } else {
            return Text("No songs.");
          }
        }),
      ],
    );
  }
}

class SongTileForAddMusic extends StatefulWidget {
  final Song song;
  SongTileForAddMusic(this.song);

  @override
  State<SongTileForAddMusic> createState() => _SongTileForAddMusicState();
}

class _SongTileForAddMusicState extends State<SongTileForAddMusic> {
  late Song song = widget.song;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return ListTileView(
        title: song.name!,
        leadingIcon: Icon(Icons.play_circle_outline),
        trailingIcon: IconButton(
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
        onTapCallback: null);
  }
}
