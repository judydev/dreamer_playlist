import 'package:dreamer_playlist/components/library_view.dart';
import 'package:dreamer_playlist/components/songlist_view.dart';
import 'package:dreamer_playlist/components/playlists_view.dart';
import 'package:flutter/material.dart';

class FavoritesView extends StatefulWidget {
  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  bool showPlaylists = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AppBar(
          title: Text("Favorites"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                style: showPlaylists
                    ? null
                    : TextButton.styleFrom(
                        side: const BorderSide(),
                      ),
                child: Text('Songs'),
                onPressed: () {
                  setState(() {
                    showPlaylists = false;
                  });
                }),
            TextButton(
              style: showPlaylists
                  ? TextButton.styleFrom(
                      side: const BorderSide(),
                    )
                  : null,
              child: Text('Playlists'),
              onPressed: () {
                setState(() {
                  showPlaylists = true;
                });
              },
            ),
          ],
        ),
        Expanded(
            child: showPlaylists
                ? PlaylistsList() // TODO: display playlist when clicked on playlist tile
                : Column(
                    children: [
                      libraryButtonBar,
                      SongListView(),
                    ],
                  )),
      ],
    );
  }
}
