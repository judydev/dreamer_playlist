import 'package:dreamer_playlist/components/future_builder_wrapper.dart';
import 'package:dreamer_playlist/components/playlist_tile.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/providers/playlist_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistsView extends StatefulWidget {
  @override
  State<PlaylistsView> createState() => _PlaylistsViewState();
}

class _PlaylistsViewState extends State<PlaylistsView> {
  late PlaylistDataProvider playlistDataProvider;
  late Future<List<Playlist>> _getAllPlaylists;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    playlistDataProvider = Provider.of<PlaylistDataProvider>(context);
    _getAllPlaylists = playlistDataProvider.getAllPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return (Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      AppBar(
        title: Text("All Playlists"),
      ),
      FutureBuilderWrapper(
        _getAllPlaylists,
        loadingText: "Loading playlists...",
        (context, snapshot) {
          List<Playlist> playlists = snapshot.data ?? [];
          return Column(
            children: [
              NewPlaylistTile(),
              ...playlists.asMap().entries.map((entry) =>
                  PlaylistTile(entry.value, entry.key, (editedProject, index) {
                    playlists[index] = editedProject;
                  })),
            ],
          );
        },
      )
    ]));
  }
}
