import 'package:dreamer_playlist/components/playlist_tile.dart';
import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistsTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      AppBar(
        title: Text("All Playlists"),
      ),
      Expanded(
        child: ListView(
          children: [NewPlaylistTile(), PlaylistsList()],
        ),
      )
    ]));
  }
}

class PlaylistsList extends StatefulWidget {
  @override
  State<PlaylistsList> createState() => _PlaylistsListState();
}

class _PlaylistsListState extends State<PlaylistsList> {
  late PlaylistDataProvider playlistDataProvider;
  late Future<List<Playlist>> _getPlaylists;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    playlistDataProvider = Provider.of<PlaylistDataProvider>(context);

    if (GetitUtil.appStates.currentTab == menuTabs[2]) {
      _getPlaylists = playlistDataProvider.getFavoritePlaylists();
    } else {
      _getPlaylists = playlistDataProvider.getAllPlaylists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWrapper(
      _getPlaylists,
      loadingText: "Loading playlists...",
      (context, snapshot) {
        List<Playlist> playlists = snapshot.data ?? [];
        return Column(
          children: [
            ...playlists.asMap().entries.map((entry) =>
                PlaylistTile(entry.value, entry.key, (editedProject, index) {
                  playlists[index] = editedProject;
                })),
          ],
        );
      },
    );
  }
}
