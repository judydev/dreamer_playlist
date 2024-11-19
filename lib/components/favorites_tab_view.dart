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
    final selectedButtonStyle = TextButton.styleFrom(
      side: BorderSide(color: Theme.of(context).colorScheme.primary),
    );

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Favorites")),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    style: showPlaylists ? null : selectedButtonStyle,
                    child: const Text('Songs'),
                    onPressed: () => setState(() => showPlaylists = false)),
                TextButton(
                  style: showPlaylists ? selectedButtonStyle : null,
                  child: const Text('Playlists'),
                  onPressed: () => setState(() => showPlaylists = true),
                ),
              ],
            ),
          ),
          Expanded(
              child: showPlaylists
                  ? ValueListenableBuilder<Playlist?>(
                      valueListenable: selectedFavoritePlaylistNotifier,
                      builder: ((context, selectedPlaylist, child) {
                        if (selectedPlaylist == null) {
                          return ListView(children: [PlaylistsList()]);
                        } else {
                          return PlaylistTabView(playlist: selectedPlaylist);
                        }
                      }))
                  : Column(
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: getLibraryButtonBar(context),
                        ),
                        Expanded(child: SongListView()),
                      ],
                    )),
        ],
      ),
    );
  }
}
