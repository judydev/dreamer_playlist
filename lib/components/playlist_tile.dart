import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/components/new_playlist_popup.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  PlaylistTile(this.playlist);

  @override
  Widget build(BuildContext context) {
    return ListTileWrapper(
      title: playlist.name!,
      leading: const Icon(Icons.queue_music),
      onTap: () async {
        if (isPlaylistsTab()) {
          await Provider.of<AppStateDataProvider>(context, listen: false)
              .updateAppState(AppStateKey.currentPlaylistId, playlist.id);
        }

        if (isFavoriteTab()) {
          selectedFavoritePlaylistNotifier.value = playlist;
        }
      },
    );
  }
}

class NewPlaylistTile extends StatelessWidget {
  final bool updateAppState;
  NewPlaylistTile({this.updateAppState = false});

  @override
  Widget build(BuildContext context) {
    return ListTileWrapper(
        leading: const Icon(Icons.add),
        title: 'New Playlist',
        onTap: () {
          showAdaptiveDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("New Playlist"),
                  content: NewPlaylistPopup(updateAppState: updateAppState),
                );
              });
        });
  }
}
