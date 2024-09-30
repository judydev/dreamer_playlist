import 'package:dreamer_playlist/components/playlist_tile.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:flutter/material.dart';

class PlaylistsTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("All Playlists")),
        body: ListView(
          children: [NewPlaylistTile(updateAppState: true), PlaylistsList(PlaylistDataService())],
        ));
  }
}

class PlaylistsList extends StatefulWidget {
  final PlaylistDataService playlistDataService;
  PlaylistsList(this.playlistDataService);

  @override
  State<PlaylistsList> createState() => _PlaylistsListState();
}

class _PlaylistsListState extends State<PlaylistsList> {
  late PlaylistDataService playlistDataService = widget.playlistDataService;
  late Future<List<Playlist>> _getPlaylists;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (isFavoriteTab()) {
      _getPlaylists = playlistDataService.getFavoritePlaylists();
    } else {
      _getPlaylists = playlistDataService.getAllPlaylists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWrapper(
      _getPlaylists,
      (context, snapshot) {
        List<Playlist> playlists = snapshot.data ?? [];
        if (playlists.isEmpty) {
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: isFavoriteTab()
                  ? const Text('No favorite playlists.')
                  : const Text('No playlists.'),
            ),
          );
        }
        return Column(
          children:
              playlists
              .asMap()
              .entries
              .map((entry) => PlaylistTile(
                  playlist: entry.value,
                  tileColor: entry.key.isEven ? highlightTileColor : null))
              .toList(),
        );
      },
    );
  }
}
