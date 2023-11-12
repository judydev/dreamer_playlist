import 'package:dreamer_playlist/helpers/notifiers.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/components/new_playlist_popup.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  PlaylistTile(this.playlist);

  @override
  Widget build(BuildContext context) {
    return ListTileWrapper(
      title: playlist.name!,
      leading: Icon(Icons.queue_music),
      onTap: () {
        if (isPlaylistsTab()) {
          Provider.of<AppStateDataProvider>(context, listen: false)
              .updateAppState(AppStateKey.currentPlaylistId, playlist.id)
              .catchError((e) => print('Error update state $e'));
        }

        if (isFavoriteTab()) {
          selectedFavoritePlaylistNotifier.value = playlist;
        }
      },
    );
  }

  deletePlaylist(context) {
    PlaylistDataProvider playlistDataProvider =
        Provider.of<PlaylistDataProvider>(context, listen: false);

    return showAlertDialogPopup(context,
        title: "Warning",
        content:
            Text("Are you sure you want to delete playlist ${playlist.name}?"),
        actions: [
      displayTextButton(context, "Yes", callback: () {
        playlistDataProvider.deletePlaylist(playlist.id).then((value) =>
            print('TODO: PlaylistTile.deletePlaylist success notification'));
      }),
      displayTextButton(context, "No")
    ]);
  }
}

class NewPlaylistTile extends StatelessWidget {
  final bool updateAppState;

  NewPlaylistTile({this.updateAppState = false});

  @override
  Widget build(BuildContext context) {
    return ListTileWrapper(
          leading: Icon(Icons.add),
      title: 'New Playlist',
          onTap: () => createNewPlaylist(context),
    );
  }

  createNewPlaylist(context) {
    String playlistName = '';

    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("New Playlist"),
          content: NewPlaylistPopup(callback: (String name) {
            playlistName = name;
          }),
          actions: [
            displayTextButton(context, "Cancel"),
            displayTextButton(context, "OK",
                callback: () => {
                      // TODO: add empty input validator, or disable OK button when empty
                      if (playlistName.trim().isEmpty)
                        {
                          print("name cannot be empty"),
                        }
                      else
                        {
                          Provider.of<PlaylistDataProvider>(context,
                                  listen: false)
                              .createPlaylist(playlistName)
                              .then((playlistId) => {
                                    if (updateAppState)
                                      {
                                        Provider.of<AppStateDataProvider>(
                                                context,
                                                listen: false)
                                            .updateAppState(
                                                AppStateKey.currentPlaylistId,
                                                playlistId),
                                      }
                                  }),

                        }
                    })
          ],
        );
      },
    );
  }
}
