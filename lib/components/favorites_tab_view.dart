import 'package:dreamer_playlist/components/library_tab_view.dart';
import 'package:dreamer_playlist/components/playlist_tab_view.dart';
import 'package:dreamer_playlist/components/songlist_view.dart';
import 'package:dreamer_playlist/components/playlists_tab_view.dart';
import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:flutter/material.dart';

class FavoritesTabView extends StatefulWidget {
  @override
  State<FavoritesTabView> createState() => _FavoritesTabViewState();
}

class _FavoritesTabViewState extends State<FavoritesTabView> {
  bool showPlaylists = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AppBar(
          title: const Text("Favorites"),
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
                child: const Text('Songs'),
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
              child: const Text('Playlists'),
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
                ? ValueListenableBuilder<Playlist?>(
                    valueListenable: selectedFavoritePlaylistNotifier,
                    builder: ((context, selectedPlaylist, child) {
                      if (selectedPlaylist == null) {
                        return PlaylistsList();
                      } else {
                        return PlaylistTabView(playlist: selectedPlaylist);
                      }
                    }))
                : Column(
                    children: [
                      getLibraryButtonBar(context),
                      SongListView(),
                    ],
                  )),
      ],
    );
  }
}
