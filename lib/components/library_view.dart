import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  print('TODO: batch edit songs (e.g. batch delete)');
                },
                icon: Icon(Icons.edit)),
            IconButton(
                onPressed: () {
                  print('TODO: Play all songs');
                },
                icon: Icon(Icons.play_circle, size: 42)),
            IconButton(
                onPressed: () {
                  print('TODO: shuffle play all songs');
                },
                icon: Icon(Icons.shuffle)),
          ],
        ),
        TextButton(
            onPressed: () {
              openFilePicker(context, null);
            },
            child: Text("Import local file to Library")),
        FutureBuilderWrapper(_getAllSongs, loadingText: 'Loading all songs...',
            (context, snapshot) {
          List<Song> songs = snapshot.data;

          if (songs.isNotEmpty) {
            return Expanded(
                child: ListView(
              children: [...songs.map((song) => SongTile(song))],
            ));
          } else {
            return Text("No songs in the library.");
          }
        }),
      ],
    );
  }
}
