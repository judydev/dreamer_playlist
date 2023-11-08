import 'package:dreamer_playlist/helpers/service_locator.dart';
import 'package:dreamer_playlist/helpers/widget_helpers.dart';
import 'package:dreamer_playlist/components/edit_playlist_view.dart';
import 'package:dreamer_playlist/models/app_state.dart';
import 'package:dreamer_playlist/models/playlist.dart';
import 'package:dreamer_playlist/database/app_state_data_provider.dart';
import 'package:dreamer_playlist/database/playlist_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatefulWidget {
  final Playlist playlist;
  final int index;
  final Function setCurrentPlaylistCallback;

  PlaylistTile(this.playlist, this.index, this.setCurrentPlaylistCallback);

  @override
  State<StatefulWidget> createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile> {
  late Playlist playlist;
  late int index;
  late Function setCurrentPlaylistCallback;

  @override
  void initState() {
    super.initState();

    playlist = widget.playlist;
    index = widget.index;
    setCurrentPlaylistCallback = widget.setCurrentPlaylistCallback;
  }

  @override
  Widget build(BuildContext context) {
    return ListTileWrapper(
      title: playlist.name!,
      leading: Icon(Icons.queue_music),
      onTap: () {
        if (GetitUtil.appStates.currentTab == menuTabs[1]) {
          Provider.of<AppStateDataProvider>(context, listen: false)
              .updateAppState(AppStateKey.currentPlaylistId, playlist.id)
              .catchError((e) => print('Error update state $e'));
        }

        GetitUtil.appStates.currentPlaylistId = playlist.id;
      },
    );
  }

  deletePlaylist(context) {
    PlaylistDataProvider playlistDataProvider =
        Provider.of<PlaylistDataProvider>(context, listen: false);

    return showAlertDialogPopup(context, "Warning",
        Text("Are you sure you want to delete playlist ${playlist.name}?"), [
      displayTextButton(context, "Yes", callback: () {
        playlistDataProvider.deletePlaylist(playlist.id).then((value) =>
            print('TODO: PlaylistTile.deletePlaylist success notification'));
      }),
      displayTextButton(context, "No")
    ]);
  }
}

class NewPlaylistTile extends StatefulWidget {
  NewPlaylistTile();

  @override
  State<StatefulWidget> createState() => _NewPlaylistTileState();
}

class _NewPlaylistTileState extends State<NewPlaylistTile> {
  @override
  Widget build(BuildContext context) {
    return ListTileWrapper(
          leading: Icon(Icons.add),
      title: 'New Playlist',
          onTap: () => createNewPlaylist(context),
    );
  }

  createNewPlaylist(context) {
    Playlist playlist = Playlist();

    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("New Playlist"),
          content: EditPlaylistView(playlist, (Playlist updated) {
            playlist = updated;
          }),
          actions: [
            displayTextButton(context, "Cancel"),
            displayTextButton(context, "OK",
                callback: () => {
                      // TODO: add empty input validator, or disable OK button when empty
                      if (playlist.name == null)
                        {
                          print("name cannot be empty"),
                        }
                      else
                        {
                          Provider.of<PlaylistDataProvider>(context,
                                  listen: false)
                              .addPlaylist(playlist)
                              .then((value) {
                            print(
                                "TODO: Playlist.addPlaylist handle success and error");
                          }),
                          Provider.of<AppStateDataProvider>(context,
                                  listen: false)
                              .updateAppState(
                                  AppStateKey.currentPlaylistId, playlist.id),
                        }
                    })
          ],
        );
      },
    );
  }
}
