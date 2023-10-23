import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/components/song_tile.dart';
import 'package:dreamer_playlist/models/song.dart';
import 'package:dreamer_playlist/database/song_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesView extends StatefulWidget {
  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  late SongDataProvider songDataProvider;
  late Future<List<Song>> _getFavoriteSongs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    songDataProvider = Provider.of<SongDataProvider>(context);
    _getFavoriteSongs = songDataProvider.getFavoriteSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AppBar(
          title: Text("Favorites"),
        ),
        FutureBuilderWrapper(_getFavoriteSongs,
            loadingText: 'Loading favorite songs...', (context, snapshot) {
          List<Song> songs = snapshot.data;
          if (songs.isNotEmpty) {
            return Column(
              children: [...songs.map((song) => SongTile(song))],
            );
          } else {
            return Text("No favorite songs.");
          }
        })
        // TODO: add favorite playlists
      ],
    );
  }
}
