import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/components/helper.dart';
import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/providers/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LibraryView extends StatefulWidget {
  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  late SongDataProvider songDataProvider;
  late Future<List<Song>> _getAllSongs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    songDataProvider = Provider.of<SongDataProvider>(context);
    _getAllSongs = songDataProvider.getAllSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AppBar(
          title: Text('All Songs'),
        ),
        Row(
          children: [
            IconButton(
                icon: Icon(Icons.play_circle_outline),
                tooltip: "Play",
                onPressed: () {
                  print('play');
                }),
            IconButton(
                icon: Icon(Icons.shuffle),
                tooltip: "Shuffle",
                onPressed: () {
                  print('shuffle');
                }),
            IconButton(
                icon: Icon(Icons.add_box_outlined),
                tooltip: "Add Music",
                onPressed: () {
                  openFilePicker(context, null);
                }),
          ],
        ),
        FutureBuilderWrapper(_getAllSongs, loadingText: 'Loading all songs...',
            (context, snapshot) {
          List<Song> songs = snapshot.data;

          if (songs.isNotEmpty) {
            return Column(
              children: [...songs.map((song) => SongTile(song))],
            );
          } else {
            return Text("No songs in the library.");
          }
        })
      ],
    );
  }
}
